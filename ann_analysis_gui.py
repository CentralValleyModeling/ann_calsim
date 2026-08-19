"""
ANN Post-Processing Statistical Analysis GUI
============================================

A Tkinter GUI that automates the EC + X2 ANN evaluation pipeline extracted
from TF_EC_X2_training_PP_tool_HZ.ipynb.

The GUI is flexible for N studies (2, 3, 4, ... base cases). Each study is a
row in a dynamic table specifying:
    - Label (e.g. Base_1_slr30)
    - EC input CSV, EC output CSV
    - X2 input CSV, X2 output CSV

Output subfolders (auto-created under the chosen output directory):
    EC_detailed_analyses/, EC_whole_period/, EC_combined_report/,
    X2_detailed_analyses/, X2_whole_period/, X2_combined_report/
"""

from __future__ import annotations

import os
import sys
import threading
import traceback
import queue
import warnings
from datetime import datetime

import tkinter as tk
from tkinter import ttk, filedialog, messagebox

warnings.filterwarnings("ignore")

# ---------------------------------------------------------------------------
# Defaults matching the original notebook
# ---------------------------------------------------------------------------
DEFAULT_DATA_DIR = r"C:\Users\hzamanis\Documents\Combined_buffer_30cm\ann_calsim_base_4Scenarios_SLR30cm_CC95_9k10kr1"
DEFAULT_OUTPUT_DIR = os.path.join(DEFAULT_DATA_DIR, "SLR30cm_ann_4Scenarios_9k10Kr1")

DEFAULT_EC_STATIONS = ["RSAC092", "ROLD024", "RSAC081", "RSAN018"]

DEFAULT_STUDIES = [
    ("Base_1_slr30", "SLR30_1_input.csv", "SLR30_1_output.csv",
     "SLR30_1_x2_input.csv", "SLR30_1_x2_output.csv"),
    ("Base_2_slr30", "SLR30_2_input.csv", "SLR30_2_output.csv",
     "SLR30_2_x2_input.csv", "SLR30_2_x2_output.csv"),
    ("Base_3_slr30", "SLR30_3_input.csv", "SLR30_3_output.csv",
     "SLR30_3_x2_input.csv", "SLR30_3_x2_output.csv"),
    ("Base_4_slr30", "SLR30_4_input.csv", "SLR30_4_output.csv",
     "SLR30_4_x2_input.csv", "SLR30_4_x2_output.csv"),
]

SUBFOLDERS = {
    "ec_detailed": "EC_detailed_analyses",
    "ec_whole":    "EC_whole_period",
    "ec_combo":    "EC_combined_report",
    "x2_detailed": "X2_detailed_analyses",
    "x2_whole":    "X2_whole_period",
    "x2_combo":    "X2_combined_report",
}

TRAIN_SLICE = slice("1940", "2021")
TEST_SLICE  = slice("1922", "1939")

UNIT_LABEL = "EC (µS/cm)"
UNIT_SHORT = "µS/cm"
X2_UNIT    = "km"
TABLE_FONTSIZE = 8


# ===========================================================================
# Statistics helper
# ===========================================================================
def compute_stats(actual, predicted):
    import numpy as np
    from sklearn.metrics import mean_squared_error, mean_absolute_error
    mask = ~(np.isnan(actual) | np.isnan(predicted))
    a, p = actual[mask], predicted[mask]
    if len(a) < 2:
        return {}
    slope = np.sum(a * p) / np.sum(a ** 2) if np.sum(a ** 2) != 0 else 1.0
    ss_res = np.sum((p - slope * a) ** 2)
    ss_tot = np.sum(p ** 2)
    r2 = 1 - ss_res / ss_tot if ss_tot != 0 else 0.0
    rmse = np.sqrt(mean_squared_error(a, p))
    mae = mean_absolute_error(a, p)
    nse = 1 - np.sum((a - p) ** 2) / np.sum((a - np.mean(a)) ** 2)
    pbias = 100.0 * np.sum(p - a) / np.sum(a) if np.sum(a) != 0 else np.nan
    obs_range = a.max() - a.min()
    nrmse = (rmse / obs_range * 100) if obs_range != 0 else np.nan
    return {"R²": round(r2, 4), "Slope": round(slope, 6),
            "RMSE": round(rmse, 4), "MAE": round(mae, 4),
            "NSE": round(nse, 4), "PBIAS": round(pbias, 4),
            "N": int(len(a)), "NRMSE": round(nrmse, 2)}


def calc_nrmse(actual, predicted):
    import numpy as np
    rmse = np.sqrt(np.mean((actual - predicted) ** 2))
    obs_range = actual.max() - actual.min()
    return (rmse / obs_range * 100) if obs_range != 0 else float("nan")


# ===========================================================================
# EC PDF page builders (mirrors notebook)
# ===========================================================================
def _ec_pdf_helpers():
    """Return a namespace of EC PDF page builders."""
    import numpy as np
    import matplotlib.pyplot as plt

    class NS:
        pass
    ns = NS()

    def ec_cover_page(pdf, station, base_label, res, subtitle_extra=""):
        fig = plt.figure(figsize=(11, 8.5)); fig.patch.set_facecolor("white")
        ax = fig.add_axes([0, 0, 1, 1]); ax.axis("off")
        ax.axhspan(0.62, 0.88, color="#4a86c8", zorder=0)
        ax.text(0.5, 0.82, "ANN Surrogate Model — System Summary Report",
                fontsize=22, fontweight="bold", color="white", ha="center", va="center", transform=ax.transAxes)
        ax.text(0.5, 0.74, f"{station} EC — {base_label} Standalone Evaluation{subtitle_extra}",
                fontsize=16, color="#d6e4f0", ha="center", va="center", transform=ax.transAxes)
        meta = [
            ("Model", f"{station} (TensorFlow / Keras .h5)"),
            ("Training Period", "1940 – 2021"),
            ("Testing Period", "1922 – 1939"),
            ("Scaling", f"MinMaxScaler {res['xscaler'].feature_range}"),
            ("Report Generated", datetime.now().strftime("%B %d, %Y  %H:%M")),
        ]
        y = 0.52
        for lbl, val in meta:
            ax.text(0.18, y, f"{lbl}:", fontsize=11, fontweight="bold", color="#1f4e79",
                    ha="left", va="center", transform=ax.transAxes)
            ax.text(0.42, y, val, fontsize=11, color="#333333",
                    ha="left", va="center", transform=ax.transAxes)
            y -= 0.05
        pdf.savefig(fig, dpi=150); plt.close(fig)

    def ec_stats_page(pdf, station, rows_data, title_suffix=""):
        col_headers = ["Period", "Scale", "R²", "RMSE", "NRMSE (%)", "MAE", "NSE", "PBIAS (%)", "N"]
        table_data = []
        for period_lbl, scale_lbl, st in rows_data:
            if not st:
                continue
            table_data.append([period_lbl, scale_lbl,
                f"{st['R²']:.4f}", f"{st['RMSE']:.4f}", f"{st.get('NRMSE', 0):.2f}",
                f"{st['MAE']:.4f}", f"{st['NSE']:.4f}", f"{st['PBIAS']:.4f}", str(st["N"])])
        fig, ax = plt.subplots(figsize=(11, 8.5)); ax.axis("off")
        ax.set_title(f"{station} — Performance Statistics{title_suffix}",
                     fontsize=14, fontweight="bold", color="#1f4e79", pad=20)
        table = ax.table(cellText=table_data, colLabels=col_headers, loc="center", cellLoc="center")
        table.auto_set_font_size(False); table.set_fontsize(TABLE_FONTSIZE)
        table.auto_set_column_width(col=list(range(len(col_headers))))
        table.scale(1.2, 2.2)
        for j in range(len(col_headers)):
            table[0, j].set_facecolor("#1f4e79")
            table[0, j].set_text_props(color="white", fontweight="bold")
        for i in range(len(table_data)):
            c = "#dce6f1" if "Training" in table_data[i][0] else "#fde9d9"
            for j in range(len(col_headers)):
                table[i + 1, j].set_facecolor(c)
        plt.tight_layout(); pdf.savefig(fig, dpi=150); plt.close(fig)

    def ec_monthly_plots_page(pdf, station, res):
        m_tr, m_te = res["monthly_train"], res["monthly_test"]
        dsm2, ann = res["dsm2_col"], res["ann_col"]
        sm_tr, sm_te = res["stats_monthly_train"], res["stats_monthly_test"]
        nrmse_tr = calc_nrmse(m_tr[dsm2].values, m_tr[ann].values)
        nrmse_te = calc_nrmse(m_te[dsm2].values, m_te[ann].values)
        fig, axes = plt.subplots(2, 2, figsize=(11, 8.5))
        fig.suptitle(f"{station} — Monthly Comparison (ANN vs DSM2)",
                     fontsize=14, fontweight="bold", color="#1f4e79", y=0.98)
        ax = axes[0, 0]
        ax.plot(m_tr.index, m_tr[dsm2], "b-", lw=1, label="DSM2")
        ax.plot(m_tr.index, m_tr[ann], "r-", lw=1, label="ANN")
        ax.set_title(f"Training  R²={sm_tr['R²']:.4f}  NSE={sm_tr['NSE']:.4f}  NRMSE={nrmse_tr:.2f}%", fontsize=10)
        ax.set_ylabel(UNIT_LABEL); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)
        ax = axes[0, 1]
        ax.plot(m_te.index, m_te[dsm2], "b-", lw=1, label="DSM2")
        ax.plot(m_te.index, m_te[ann], "r-", lw=1, label="ANN")
        ax.set_title(f"Testing  R²={sm_te['R²']:.4f}  NSE={sm_te['NSE']:.4f}  NRMSE={nrmse_te:.2f}%", fontsize=10)
        ax.set_ylabel(UNIT_LABEL); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)
        ax = axes[1, 0]
        ax.scatter(m_tr[dsm2], m_tr[ann], s=10, alpha=0.6, c="steelblue", edgecolors="none")
        lo = min(m_tr.min().min(), 0); hi = m_tr.max().max() * 1.05
        ax.plot([lo, hi], [lo, hi], "k--", lw=0.8)
        ax.set_title(f"Scatter Training  R²={sm_tr['R²']:.4f}", fontsize=10)
        ax.set_xlabel(f"DSM2 {UNIT_LABEL}"); ax.set_ylabel(f"ANN {UNIT_LABEL}"); ax.grid(True, alpha=0.3)
        ax = axes[1, 1]
        ax.scatter(m_te[dsm2], m_te[ann], s=10, alpha=0.6, c="seagreen", edgecolors="none")
        lo = min(m_te.min().min(), 0); hi = m_te.max().max() * 1.05
        ax.plot([lo, hi], [lo, hi], "k--", lw=0.8)
        ax.set_title(f"Scatter Testing  R²={sm_te['R²']:.4f}", fontsize=10)
        ax.set_xlabel(f"DSM2 {UNIT_LABEL}"); ax.set_ylabel(f"ANN {UNIT_LABEL}"); ax.grid(True, alpha=0.3)
        plt.tight_layout(rect=[0, 0, 1, 0.95]); pdf.savefig(fig, dpi=150); plt.close(fig)

    def ec_daily_ts_page(pdf, station, res):
        d_tr, d_te = res["daily_train"], res["daily_test"]
        dsm2, ann = res["dsm2_col"], res["ann_col"]
        sd_tr, sd_te = res["stats_daily_train"], res["stats_daily_test"]
        nrmse_d_tr = calc_nrmse(d_tr[dsm2].values, d_tr[ann].values)
        nrmse_d_te = calc_nrmse(d_te[dsm2].values, d_te[ann].values)
        fig, axes = plt.subplots(2, 1, figsize=(11, 8.5))
        fig.suptitle(f"{station} — Daily Time Series",
                     fontsize=14, fontweight="bold", color="#1f4e79", y=0.98)
        ax = axes[0]
        ax.plot(d_tr.index, d_tr[dsm2], "b-", lw=0.4, alpha=0.7, label="DSM2")
        ax.plot(d_tr.index, d_tr[ann], "r-", lw=0.4, alpha=0.7, label="ANN")
        ax.set_title(f"Training  R²={sd_tr['R²']:.4f}  RMSE={sd_tr['RMSE']:.4f}  NSE={sd_tr['NSE']:.4f}  NRMSE={nrmse_d_tr:.2f}%", fontsize=10)
        ax.set_ylabel(UNIT_LABEL); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)
        ax = axes[1]
        ax.plot(d_te.index, d_te[dsm2], "b-", lw=0.4, alpha=0.7, label="DSM2")
        ax.plot(d_te.index, d_te[ann], "r-", lw=0.4, alpha=0.7, label="ANN")
        ax.set_title(f"Testing  R²={sd_te['R²']:.4f}  RMSE={sd_te['RMSE']:.4f}  NSE={sd_te['NSE']:.4f}  NRMSE={nrmse_d_te:.2f}%", fontsize=10)
        ax.set_ylabel(UNIT_LABEL); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)
        plt.tight_layout(rect=[0, 0, 1, 0.95]); pdf.savefig(fig, dpi=150); plt.close(fig)

    ns.ec_cover_page = ec_cover_page
    ns.ec_stats_page = ec_stats_page
    ns.ec_monthly_plots_page = ec_monthly_plots_page
    ns.ec_daily_ts_page = ec_daily_ts_page
    return ns


# ===========================================================================
# Whole-period PDF helpers (EC + X2)
# ===========================================================================
def _wp_pdf_helpers():
    import numpy as np
    import matplotlib.pyplot as plt

    class NS:
        pass
    ns = NS()

    def ec_wp_cover(pdf, station, base_label, wp):
        fig = plt.figure(figsize=(11, 8.5)); ax = fig.add_axes([0, 0, 1, 1]); ax.axis("off")
        ax.axhspan(0.62, 0.88, color="#4a86c8")
        ax.text(0.5, 0.82, "ANN Surrogate — Whole-Period Report",
                fontsize=22, fontweight="bold", color="white", ha="center", va="center", transform=ax.transAxes)
        ax.text(0.5, 0.74, f"{station} EC — {base_label}", fontsize=16, color="#d6e4f0",
                ha="center", va="center", transform=ax.transAxes)
        ax.text(0.5, 0.55, f"Evaluation: 1922 – 2021\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
                fontsize=12, ha="center", va="center", transform=ax.transAxes)
        pdf.savefig(fig, dpi=150); plt.close(fig)

    def ec_wp_stats_page(pdf, station, st_d, st_m, title_suffix=""):
        col_headers = ["Period", "Scale", "R²", "RMSE", "NRMSE (%)", "MAE", "NSE", "PBIAS (%)", "N"]
        rows = []
        for lbl, st in [("Daily", st_d), ("Monthly", st_m)]:
            if st:
                rows.append(["1922–2021", lbl,
                    f"{st['R²']:.4f}", f"{st['RMSE']:.4f}", f"{st.get('NRMSE',0):.2f}",
                    f"{st['MAE']:.4f}", f"{st['NSE']:.4f}", f"{st['PBIAS']:.4f}", str(st["N"])])
        fig, ax = plt.subplots(figsize=(11, 8.5)); ax.axis("off")
        ax.set_title(f"{station} — Whole-Period Statistics{title_suffix}",
                     fontsize=14, fontweight="bold", color="#1f4e79", pad=20)
        table = ax.table(cellText=rows, colLabels=col_headers, loc="center", cellLoc="center")
        table.auto_set_font_size(False); table.set_fontsize(TABLE_FONTSIZE); table.scale(1.2, 2.2)
        for j in range(len(col_headers)):
            table[0, j].set_facecolor("#1f4e79")
            table[0, j].set_text_props(color="white", fontweight="bold")
        plt.tight_layout(); pdf.savefig(fig, dpi=150); plt.close(fig)

    def ec_wp_monthly_page(pdf, station, wp):
        m = wp["monthly_full"]; dsm2, ann = wp["dsm2_col"], wp["ann_col"]
        st_m = wp["stats_monthly"]
        nrmse = calc_nrmse(m[dsm2].values, m[ann].values)
        fig, axes = plt.subplots(2, 2, figsize=(11, 8.5))
        fig.suptitle(f"{station} — Monthly Whole-Period (1922–2021)",
                     fontsize=14, fontweight="bold", color="#1f4e79", y=0.98)
        ax = axes[0, 0]
        ax.plot(m.index, m[dsm2], "b-", lw=1, label="DSM2"); ax.plot(m.index, m[ann], "r-", lw=1, label="ANN")
        ax.set_title(f"R²={st_m['R²']:.4f}  NSE={st_m['NSE']:.4f}  NRMSE={nrmse:.2f}%", fontsize=10)
        ax.set_ylabel(UNIT_LABEL); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)
        ax = axes[0, 1]
        ax.scatter(m[dsm2], m[ann], s=10, alpha=0.6, c="darkorange")
        lo = min(m.min().min(), 0); hi = m.max().max() * 1.05
        ax.plot([lo, hi], [lo, hi], "k--", lw=0.8)
        ax.set_title(f"Scatter R²={st_m['R²']:.4f}", fontsize=10)
        ax.set_xlabel(f"DSM2 {UNIT_LABEL}"); ax.set_ylabel(f"ANN {UNIT_LABEL}"); ax.grid(True, alpha=0.3)
        mres = m[ann] - m[dsm2]; mae = mres.abs().mean()
        ax = axes[1, 0]
        ax.plot(m.index, mres, "b-", lw=1); ax.axhline(0, color="k", lw=0.8, ls="--")
        ax.axhline(mae, color="r", lw=1); ax.axhline(-mae, color="r", lw=1)
        ax.set_title(f"Monthly Residuals  Mean|Res|={mae:.3f}", fontsize=10)
        ax.set_ylabel(f"ANN − DSM2 ({UNIT_SHORT})"); ax.grid(True, alpha=0.3)
        ax = axes[1, 1]
        ax.hist(mres, bins=30, color="darkorange", alpha=0.7, edgecolor="white")
        ax.axvline(0, color="k", ls="--"); ax.axvline(mres.mean(), color="r")
        ax.set_title("Monthly Residual Distribution", fontsize=10)
        ax.set_xlabel(f"Residual ({UNIT_SHORT})"); ax.set_ylabel("Count"); ax.grid(True, alpha=0.3)
        plt.tight_layout(rect=[0, 0, 1, 0.95]); pdf.savefig(fig, dpi=150); plt.close(fig)

    def ec_wp_daily_page(pdf, station, wp):
        d = wp["daily_full"]; dsm2, ann = wp["dsm2_col"], wp["ann_col"]
        st_d = wp["stats_daily"]
        nrmse = calc_nrmse(d[dsm2].values, d[ann].values)
        fig, axes = plt.subplots(2, 2, figsize=(11, 8.5))
        fig.suptitle(f"{station} — Daily Whole-Period (1922–2021)",
                     fontsize=14, fontweight="bold", color="#1f4e79", y=0.98)
        ax = axes[0, 0]
        ax.plot(d.index, d[dsm2], "b-", lw=0.4, alpha=0.7, label="DSM2")
        ax.plot(d.index, d[ann], "r-", lw=0.4, alpha=0.7, label="ANN")
        ax.set_title(f"R²={st_d['R²']:.4f}  RMSE={st_d['RMSE']:.4f}  NSE={st_d['NSE']:.4f}  NRMSE={nrmse:.2f}%", fontsize=9)
        ax.set_ylabel(UNIT_LABEL); ax.legend(fontsize=7); ax.grid(True, alpha=0.3)
        ax = axes[0, 1]
        ax.scatter(d[dsm2], d[ann], s=1, alpha=0.15, c="darkorange")
        lo = min(d.min().min(), 0); hi = d.max().max() * 1.05
        ax.plot([lo, hi], [lo, hi], "k--", lw=0.8)
        ax.set_title(f"Daily Scatter R²={st_d['R²']:.4f}", fontsize=10)
        ax.set_xlabel(f"DSM2 {UNIT_LABEL}"); ax.set_ylabel(f"ANN {UNIT_LABEL}"); ax.grid(True, alpha=0.3)
        dres = d[ann] - d[dsm2]
        ax = axes[1, 0]
        ax.plot(d.index, dres, "b-", lw=0.3, alpha=0.5); ax.axhline(0, color="k", ls="--")
        ax.axhline(dres.mean(), color="r")
        ax.set_title("Daily Residuals", fontsize=10); ax.grid(True, alpha=0.3)
        ax = axes[1, 1]
        ax.hist(dres, bins=50, color="darkorange", alpha=0.7, edgecolor="white")
        ax.axvline(0, color="k", ls="--"); ax.axvline(dres.mean(), color="r")
        ax.set_title("Daily Residual Distribution", fontsize=10)
        ax.set_xlabel(f"Residual ({UNIT_SHORT})"); ax.set_ylabel("Count"); ax.grid(True, alpha=0.3)
        plt.tight_layout(rect=[0, 0, 1, 0.95]); pdf.savefig(fig, dpi=150); plt.close(fig)

    def ec_wp_combined_stats_page(pdf, base_wp, base_label, scale_filter=None, title_suffix=""):
        col_headers = ["Station", "Scale", "R²", "RMSE", "NRMSE (%)", "MAE", "NSE", "PBIAS (%)", "N"]
        table_data = []
        for station in base_wp:
            wp = base_wp[station]
            for slbl, st in [("Daily", wp["stats_daily"]), ("Monthly", wp["stats_monthly"])]:
                if scale_filter and slbl != scale_filter:
                    continue
                if not st:
                    continue
                table_data.append([station, slbl,
                    f"{st['R²']:.4f}", f"{st['RMSE']:.2f}", f"{st.get('NRMSE',0):.2f}",
                    f"{st['MAE']:.2f}", f"{st['NSE']:.4f}", f"{st['PBIAS']:.2f}", str(st["N"])])
        rows_per_page = 24
        for page_start in range(0, len(table_data), rows_per_page):
            page_rows = table_data[page_start:page_start + rows_per_page]
            fig, ax = plt.subplots(figsize=(11, 8.5)); ax.axis("off")
            ax.set_title(f"EC Stations ({base_label}) — Whole-Period{title_suffix}",
                         fontsize=14, fontweight="bold", color="#1f4e79", pad=20)
            table = ax.table(cellText=page_rows, colLabels=col_headers, loc="center", cellLoc="center")
            table.auto_set_font_size(False); table.set_fontsize(TABLE_FONTSIZE)
            table.scale(1.0, 1.6)
            for j in range(len(col_headers)):
                table[0, j].set_facecolor("#1f4e79")
                table[0, j].set_text_props(color="white", fontweight="bold")
            plt.tight_layout(); pdf.savefig(fig, dpi=150); plt.close(fig)

    # X2 pages
    def x2_wp_cover(pdf, base_label, wp, subtitle_extra=""):
        fig = plt.figure(figsize=(11, 8.5)); ax = fig.add_axes([0, 0, 1, 1]); ax.axis("off")
        ax.axhspan(0.62, 0.88, color="#4a86c8")
        ax.text(0.5, 0.82, "ANN Surrogate — Whole-Period Report",
                fontsize=22, fontweight="bold", color="white", ha="center", va="center", transform=ax.transAxes)
        ax.text(0.5, 0.74, f"X2_DIS — {base_label}{subtitle_extra}", fontsize=16, color="#d6e4f0",
                ha="center", va="center", transform=ax.transAxes)
        ax.text(0.5, 0.55, f"Evaluation: 1922 – 2021\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
                fontsize=12, ha="center", va="center", transform=ax.transAxes)
        pdf.savefig(fig, dpi=150); plt.close(fig)

    def x2_wp_stats_page(pdf, base_label, st_d, st_m, title_suffix=""):
        col_headers = ["Period", "Scale", "R²", "RMSE", "NRMSE (%)", "MAE", "NSE", "PBIAS (%)", "N"]
        rows = []
        for lbl, st in [("Daily", st_d), ("Monthly", st_m)]:
            if st:
                rows.append(["1922–2021", lbl,
                    f"{st['R²']:.4f}", f"{st['RMSE']:.4f}", f"{st.get('NRMSE',0):.2f}",
                    f"{st['MAE']:.4f}", f"{st['NSE']:.4f}", f"{st['PBIAS']:.4f}", str(st["N"])])
        fig, ax = plt.subplots(figsize=(11, 8.5)); ax.axis("off")
        ax.set_title(f"X2_DIS ({base_label}) — Whole-Period Statistics{title_suffix}",
                     fontsize=14, fontweight="bold", color="#1f4e79", pad=20)
        table = ax.table(cellText=rows, colLabels=col_headers, loc="center", cellLoc="center")
        table.auto_set_font_size(False); table.set_fontsize(TABLE_FONTSIZE); table.scale(1.2, 2.2)
        for j in range(len(col_headers)):
            table[0, j].set_facecolor("#1f4e79")
            table[0, j].set_text_props(color="white", fontweight="bold")
        plt.tight_layout(); pdf.savefig(fig, dpi=150); plt.close(fig)

    def x2_wp_monthly_page(pdf, base_label, wp):
        m = wp["monthly_full"]; st_m = wp["stats_monthly"]
        nrmse = calc_nrmse(m["X2_DSM2"].values, m["X2_ANN_pred"].values)
        fig, axes = plt.subplots(2, 2, figsize=(11, 8.5))
        fig.suptitle(f"X2_DIS ({base_label}) — Monthly Whole-Period", fontsize=14, fontweight="bold", color="#1f4e79")
        ax = axes[0, 0]
        ax.plot(m.index, m["X2_DSM2"], "b-", lw=1, label="DSM2")
        ax.plot(m.index, m["X2_ANN_pred"], "r-", lw=1, label="ANN")
        ax.set_title(f"R²={st_m['R²']:.4f} NSE={st_m['NSE']:.4f} NRMSE={nrmse:.2f}%", fontsize=10)
        ax.set_ylabel(f"X2 ({X2_UNIT})"); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)
        ax = axes[0, 1]
        ax.scatter(m["X2_DSM2"], m["X2_ANN_pred"], s=10, alpha=0.6, c="darkorange")
        lo = min(m.min().min(), 0); hi = m.max().max() * 1.05
        ax.plot([lo, hi], [lo, hi], "k--", lw=0.8)
        ax.set_title(f"Scatter R²={st_m['R²']:.4f}", fontsize=10); ax.grid(True, alpha=0.3)
        mres = m["X2_ANN_pred"] - m["X2_DSM2"]; mae = mres.abs().mean()
        ax = axes[1, 0]
        ax.plot(m.index, mres, "b-", lw=1); ax.axhline(0, color="k", ls="--")
        ax.axhline(mae, color="r"); ax.axhline(-mae, color="r")
        ax.set_title(f"Monthly Residuals Mean|Res|={mae:.3f}", fontsize=10); ax.grid(True, alpha=0.3)
        ax = axes[1, 1]
        ax.hist(mres, bins=30, color="darkorange", alpha=0.7, edgecolor="white")
        ax.axvline(0, color="k", ls="--"); ax.axvline(mres.mean(), color="r")
        ax.set_title("Residual Distribution", fontsize=10); ax.grid(True, alpha=0.3)
        plt.tight_layout(rect=[0, 0, 1, 0.95]); pdf.savefig(fig, dpi=150); plt.close(fig)

    def x2_wp_daily_page(pdf, base_label, wp):
        d = wp["daily_full"]; st_d = wp["stats_daily"]
        nrmse = calc_nrmse(d["X2_DSM2"].values, d["X2_ANN_pred"].values)
        fig, axes = plt.subplots(2, 2, figsize=(11, 8.5))
        fig.suptitle(f"X2_DIS ({base_label}) — Daily Whole-Period", fontsize=14, fontweight="bold", color="#1f4e79")
        ax = axes[0, 0]
        ax.plot(d.index, d["X2_DSM2"], "b-", lw=0.4, alpha=0.7, label="DSM2")
        ax.plot(d.index, d["X2_ANN_pred"], "r-", lw=0.4, alpha=0.7, label="ANN")
        ax.set_title(f"R²={st_d['R²']:.4f} RMSE={st_d['RMSE']:.4f} NSE={st_d['NSE']:.4f} NRMSE={nrmse:.2f}%", fontsize=9)
        ax.set_ylabel(f"X2 ({X2_UNIT})"); ax.legend(fontsize=7); ax.grid(True, alpha=0.3)
        ax = axes[0, 1]
        ax.scatter(d["X2_DSM2"], d["X2_ANN_pred"], s=1, alpha=0.15, c="darkorange")
        lo = min(d.min().min(), 0); hi = d.max().max() * 1.05
        ax.plot([lo, hi], [lo, hi], "k--", lw=0.8)
        ax.set_title(f"Daily Scatter R²={st_d['R²']:.4f}", fontsize=10); ax.grid(True, alpha=0.3)
        dres = d["X2_ANN_pred"] - d["X2_DSM2"]
        ax = axes[1, 0]
        ax.plot(d.index, dres, "b-", lw=0.3, alpha=0.5); ax.axhline(0, color="k", ls="--")
        ax.axhline(dres.mean(), color="r")
        ax.set_title("Daily Residuals", fontsize=10); ax.grid(True, alpha=0.3)
        ax = axes[1, 1]
        ax.hist(dres, bins=50, color="darkorange", alpha=0.7, edgecolor="white")
        ax.axvline(0, color="k", ls="--"); ax.axvline(dres.mean(), color="r")
        ax.set_title("Daily Residual Distribution", fontsize=10); ax.grid(True, alpha=0.3)
        plt.tight_layout(rect=[0, 0, 1, 0.95]); pdf.savefig(fig, dpi=150); plt.close(fig)

    ns.ec_wp_cover = ec_wp_cover
    ns.ec_wp_stats_page = ec_wp_stats_page
    ns.ec_wp_monthly_page = ec_wp_monthly_page
    ns.ec_wp_daily_page = ec_wp_daily_page
    ns.ec_wp_combined_stats_page = ec_wp_combined_stats_page
    ns.x2_wp_cover = x2_wp_cover
    ns.x2_wp_stats_page = x2_wp_stats_page
    ns.x2_wp_monthly_page = x2_wp_monthly_page
    ns.x2_wp_daily_page = x2_wp_daily_page
    return ns


# ===========================================================================
# Main pipeline
# ===========================================================================
def run_pipeline(path_data, output_base, studies, ec_stations, log):
    """
    studies: list of tuples (label, ec_in, ec_out, x2_in, x2_out)
    ec_stations: list of EC station names
    log: callable(msg) for progress messages
    """
    # ensure annutilsr can be imported from path_data
    if path_data not in sys.path:
        sys.path.insert(0, path_data)

    # annutilsr.load_model uses RELATIVE paths (e.g. 'RSAC092.h5'), so we must
    # cd into the folder that contains the .h5 files and *-xyscaler.dump files.
    original_cwd = os.getcwd()
    os.chdir(path_data)
    log(f"Working directory set to: {path_data}")

    import numpy as np
    import pandas as pd
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.backends.backend_pdf import PdfPages

    log("Importing annutilsr (this may take 10-30 s while TensorFlow loads)...")
    try:
        import annutilsr
    except Exception as e:
        os.chdir(original_cwd)
        raise RuntimeError(f"Could not import annutilsr from {path_data}: {e}")
    log("annutilsr imported successfully.")

    # -----------------------------------------------------------------
    # Patch annutilsr.load_model to use compile=False.
    # Old .h5 files were saved with an older Keras version whose
    # 'keras.metrics.mse' loss reference can't be deserialized in
    # Keras 3 / TF 2.16+. We only need the model for inference, so
    # skipping the optimizer / loss compilation is safe.
    # -----------------------------------------------------------------
    import joblib
    from tensorflow import keras as _keras
    _ANNModel = annutilsr.ANNModel

    def _patched_load_model(model_name):
        model = _keras.models.load_model(f"{model_name}.h5", compile=False)
        xscaler, yscaler = joblib.load(f"{model_name}-xyscaler.dump")
        return _ANNModel(model_name, model, xscaler, yscaler)

    annutilsr.load_model = _patched_load_model
    log("Patched annutilsr.load_model to use compile=False (Keras 3 compatibility).")

    # Sanity check: warn if expected model files are missing
    missing = [f"{s}.h5" for s in ec_stations if not os.path.exists(os.path.join(path_data, f"{s}.h5"))]
    if not os.path.exists(os.path.join(path_data, "X2_DIS.h5")):
        missing.append("X2_DIS.h5")
    if missing:
        log(f"WARNING: missing model files in {path_data}: {missing}")

    # --- Create output subfolders ---
    out_dirs = {k: os.path.join(output_base, v) for k, v in SUBFOLDERS.items()}
    for d in out_dirs.values():
        os.makedirs(d, exist_ok=True)
    log(f"Output folders ready under: {output_base}")

    ec_helpers = _ec_pdf_helpers()
    wp_helpers = _wp_pdf_helpers()

    # =============================================================
    # PHASE 1: EC per-case predictions (detailed)
    # =============================================================
    log("\n" + "=" * 70)
    log("PHASE 1: EC standalone prediction (train/test) per base case")
    log("=" * 70)
    ec_results = {}
    ec_dir = out_dirs["ec_detailed"]

    for base_label, in_file, out_file, _x2i, _x2o in studies:
        log(f"\n--- {base_label}: {in_file} / {out_file} ---")
        try:
            ec_dfin_raw = pd.read_csv(os.path.join(path_data, in_file), index_col=0, parse_dates=True)
            ec_dfout_raw = pd.read_csv(os.path.join(path_data, out_file), index_col=0, parse_dates=True)
        except Exception as e:
            log(f"  ERROR reading files: {e}")
            continue
        log(f"  Input {ec_dfin_raw.shape}  Output {ec_dfout_raw.shape}")
        ec_results[base_label] = {}

        for station in ec_stations:
            output_col = f"{station}_EC"
            if output_col not in ec_dfout_raw.columns:
                log(f"    skip {station}: column {output_col} not found")
                continue
            try:
                model = annutilsr.load_model(station)
            except Exception as e:
                log(f"    skip {station}: cannot load model ({e})")
                continue
            xs, ys = model.xscaler, model.yscaler
            dfout_single = ec_dfout_raw[[output_col]].copy()
            dfin_sync, dfout_sync = annutilsr.synchronize(ec_dfin_raw, dfout_single)
            dfin_scaled = pd.DataFrame(xs.transform(dfin_sync), index=dfin_sync.index, columns=dfin_sync.columns)
            dfout_scaled = pd.DataFrame(ys.transform(dfout_sync), index=dfout_sync.index, columns=dfout_sync.columns)
            dfx_ant = annutilsr.create_antecedent_inputs(dfin_scaled)
            dfy_ali = annutilsr.trim_output_to_index(dfout_scaled, dfx_ant.index)

            x_tr = dfx_ant.loc[TRAIN_SLICE]; y_tr = dfy_ali.loc[TRAIN_SLICE]
            x_te = dfx_ant.loc[TEST_SLICE];  y_te = dfy_ali.loc[TEST_SLICE]

            yp_tr = pd.DataFrame(ys.inverse_transform(model.model.predict(x_tr.values, verbose=0)),
                                 index=x_tr.index, columns=[f"{station}_ANN"])
            yp_te = pd.DataFrame(ys.inverse_transform(model.model.predict(x_te.values, verbose=0)),
                                 index=x_te.index, columns=[f"{station}_ANN"])
            ya_tr = pd.DataFrame(ys.inverse_transform(y_tr.values),
                                 index=y_tr.index, columns=[f"{station}_DSM2"])
            ya_te = pd.DataFrame(ys.inverse_transform(y_te.values),
                                 index=y_te.index, columns=[f"{station}_DSM2"])

            d_tr = pd.concat([ya_tr, yp_tr], axis=1)
            d_te = pd.concat([ya_te, yp_te], axis=1)
            m_tr = d_tr.resample("ME").mean().dropna()
            m_te = d_te.resample("ME").mean().dropna()

            d_tr.to_csv(os.path.join(ec_dir, f"{station}_{base_label}_daily_train_comparison.csv"))
            d_te.to_csv(os.path.join(ec_dir, f"{station}_{base_label}_daily_test_comparison.csv"))
            m_tr.to_csv(os.path.join(ec_dir, f"{station}_{base_label}_monthly_train_comparison.csv"))
            m_te.to_csv(os.path.join(ec_dir, f"{station}_{base_label}_monthly_test_comparison.csv"))

            dsm2_col = f"{station}_DSM2"; ann_col = f"{station}_ANN"
            st_d_tr = compute_stats(d_tr[dsm2_col].values, d_tr[ann_col].values)
            st_d_te = compute_stats(d_te[dsm2_col].values, d_te[ann_col].values)
            st_m_tr = compute_stats(m_tr[dsm2_col].values, m_tr[ann_col].values)
            st_m_te = compute_stats(m_te[dsm2_col].values, m_te[ann_col].values)

            log(f"    {station}: dailyTrain R²={st_d_tr.get('R²','?')}  monthlyTest R²={st_m_te.get('R²','?')}")

            ec_results[base_label][station] = dict(
                daily_train=d_tr, daily_test=d_te, monthly_train=m_tr, monthly_test=m_te,
                dsm2_col=dsm2_col, ann_col=ann_col,
                stats_daily_train=st_d_tr, stats_daily_test=st_d_te,
                stats_monthly_train=st_m_tr, stats_monthly_test=st_m_te,
                xscaler=xs, yscaler=ys)

    # combined EC stats CSV
    all_ec_stats = []
    for base_label, stations in ec_results.items():
        for station, r in stations.items():
            for period, scale, key in [
                ("Training (1940-2021)", "Daily",   "stats_daily_train"),
                ("Training (1940-2021)", "Monthly", "stats_monthly_train"),
                ("Testing (1922-1939)",  "Daily",   "stats_daily_test"),
                ("Testing (1922-1939)",  "Monthly", "stats_monthly_test"),
            ]:
                s = r[key]
                if s:
                    all_ec_stats.append({"Base": base_label, "Station": station,
                                         "Period": period, "Scale": scale, **s})
    if all_ec_stats:
        pd.DataFrame(all_ec_stats).to_csv(
            os.path.join(ec_dir, "EC_all_stations_all_cases_prediction_statistics.csv"), index=False)
    log(f"EC detailed stats saved -> {ec_dir}")

    # EC per-case detailed PDFs
    log("\nGenerating EC per-case detailed PDFs...")
    for base_label, base_res in ec_results.items():
        if not base_res:
            continue
        pdf_path = os.path.join(ec_dir, f"EC_{base_label}_Full_Report_Daily_Monthly.pdf")
        with PdfPages(pdf_path) as pdf:
            for station, res in base_res.items():
                ec_helpers.ec_cover_page(pdf, station, base_label, res)
                ec_helpers.ec_stats_page(pdf, station, [
                    ("Training (1940–2021)", "Daily",   res["stats_daily_train"]),
                    ("Training (1940–2021)", "Monthly", res["stats_monthly_train"]),
                    ("Testing (1922–1939)",  "Daily",   res["stats_daily_test"]),
                    ("Testing (1922–1939)",  "Monthly", res["stats_monthly_test"]),
                ], " (Daily & Monthly)")
                ec_helpers.ec_monthly_plots_page(pdf, station, res)
                ec_helpers.ec_daily_ts_page(pdf, station, res)
        log(f"  -> {os.path.basename(pdf_path)}")

    # =============================================================
    # PHASE 2: X2 per-case predictions (detailed)
    # =============================================================
    log("\n" + "=" * 70)
    log("PHASE 2: X2 standalone prediction (train/test) per base case")
    log("=" * 70)
    x2_dir = out_dirs["x2_detailed"]
    x2_results = {}
    try:
        x2_model = annutilsr.load_model("X2_DIS")
    except Exception as e:
        log(f"  ERROR loading X2_DIS model: {e}")
        x2_model = None

    if x2_model is not None:
        xscaler, yscaler = x2_model.xscaler, x2_model.yscaler
        for base_label, _eci, _eco, in_file, out_file in studies:
            log(f"\n--- {base_label}: {in_file} / {out_file} ---")
            try:
                dfin_raw = pd.read_csv(os.path.join(path_data, in_file), index_col=0, parse_dates=True)
                dfout_raw = pd.read_csv(os.path.join(path_data, out_file), index_col=0, parse_dates=True)
            except Exception as e:
                log(f"  ERROR reading X2 files: {e}")
                continue

            dfin_sync, dfout_sync = annutilsr.synchronize(dfin_raw, dfout_raw)
            dfin_scaled = pd.DataFrame(xscaler.transform(dfin_sync), index=dfin_sync.index, columns=dfin_sync.columns)
            dfout_scaled = pd.DataFrame(yscaler.transform(dfout_sync), index=dfout_sync.index, columns=dfout_sync.columns)
            dfx_ant = annutilsr.create_antecedent_inputs(dfin_scaled)
            dfy_ali = annutilsr.trim_output_to_index(dfout_scaled, dfx_ant.index)

            x_tr = dfx_ant.loc[TRAIN_SLICE]; y_tr = dfy_ali.loc[TRAIN_SLICE]
            x_te = dfx_ant.loc[TEST_SLICE];  y_te = dfy_ali.loc[TEST_SLICE]

            yp_tr = pd.DataFrame(yscaler.inverse_transform(x2_model.model.predict(x_tr.values, verbose=0)),
                                 index=x_tr.index, columns=["X2_ANN_pred"])
            yp_te = pd.DataFrame(yscaler.inverse_transform(x2_model.model.predict(x_te.values, verbose=0)),
                                 index=x_te.index, columns=["X2_ANN_pred"])
            ya_tr = pd.DataFrame(yscaler.inverse_transform(y_tr.values),
                                 index=y_tr.index, columns=["X2_DSM2"])
            ya_te = pd.DataFrame(yscaler.inverse_transform(y_te.values),
                                 index=y_te.index, columns=["X2_DSM2"])

            d_tr = pd.concat([ya_tr, yp_tr], axis=1)
            d_te = pd.concat([ya_te, yp_te], axis=1)
            m_tr = d_tr.resample("ME").mean().dropna()
            m_te = d_te.resample("ME").mean().dropna()

            d_tr.to_csv(os.path.join(x2_dir, f"X2_DIS_{base_label}_daily_train_comparison.csv"))
            d_te.to_csv(os.path.join(x2_dir, f"X2_DIS_{base_label}_daily_test_comparison.csv"))
            m_tr.to_csv(os.path.join(x2_dir, f"X2_DIS_{base_label}_monthly_train_comparison.csv"))
            m_te.to_csv(os.path.join(x2_dir, f"X2_DIS_{base_label}_monthly_test_comparison.csv"))

            st_d_tr = compute_stats(d_tr["X2_DSM2"].values, d_tr["X2_ANN_pred"].values)
            st_d_te = compute_stats(d_te["X2_DSM2"].values, d_te["X2_ANN_pred"].values)
            st_m_tr = compute_stats(m_tr["X2_DSM2"].values, m_tr["X2_ANN_pred"].values)
            st_m_te = compute_stats(m_te["X2_DSM2"].values, m_te["X2_ANN_pred"].values)

            log(f"    dailyTrain R²={st_d_tr.get('R²','?')}  monthlyTest R²={st_m_te.get('R²','?')}")

            x2_results[base_label] = dict(
                daily_train=d_tr, daily_test=d_te, monthly_train=m_tr, monthly_test=m_te,
                stats_daily_train=st_d_tr, stats_daily_test=st_d_te,
                stats_monthly_train=st_m_tr, stats_monthly_test=st_m_te,
                xscaler=xscaler, yscaler=yscaler)

        all_x2_stats = []
        for base_label, r in x2_results.items():
            for period, scale, key in [
                ("Training (1940-2021)", "Daily",   "stats_daily_train"),
                ("Training (1940-2021)", "Monthly", "stats_monthly_train"),
                ("Testing (1922-1939)",  "Daily",   "stats_daily_test"),
                ("Testing (1922-1939)",  "Monthly", "stats_monthly_test"),
            ]:
                s = r[key]
                if s:
                    all_x2_stats.append({"Base": base_label, "Period": period, "Scale": scale, **s})
        if all_x2_stats:
            pd.DataFrame(all_x2_stats).to_csv(
                os.path.join(x2_dir, "X2_all_cases_prediction_statistics.csv"), index=False)
        log(f"X2 detailed stats saved -> {x2_dir}")

    # =============================================================
    # PHASE 3: EC whole-period
    # =============================================================
    log("\n" + "=" * 70)
    log("PHASE 3: EC whole-period (1922–2021)")
    log("=" * 70)
    ec_wp_dir = out_dirs["ec_whole"]
    ec_wp = {}
    all_ec_wp_stats = []
    for base_label, stations in ec_results.items():
        ec_wp[base_label] = {}
        for station, res in stations.items():
            d_full = pd.concat([res["daily_train"], res["daily_test"]]).sort_index()
            d_full = d_full[~d_full.index.duplicated(keep="first")]
            m_full = d_full.resample("ME").mean().dropna()
            st_d = compute_stats(d_full[res["dsm2_col"]].values, d_full[res["ann_col"]].values)
            st_m = compute_stats(m_full[res["dsm2_col"]].values, m_full[res["ann_col"]].values)
            ec_wp[base_label][station] = dict(
                daily_full=d_full, monthly_full=m_full,
                dsm2_col=res["dsm2_col"], ann_col=res["ann_col"],
                stats_daily=st_d, stats_monthly=st_m,
                xscaler=res["xscaler"], yscaler=res["yscaler"])
            for scale, st in [("Daily", st_d), ("Monthly", st_m)]:
                if st:
                    all_ec_wp_stats.append({"Base": base_label, "Station": station,
                                             "Period": "Whole (1922-2021)", "Scale": scale, **st})
    if all_ec_wp_stats:
        pd.DataFrame(all_ec_wp_stats).to_csv(
            os.path.join(ec_wp_dir, "EC_all_stations_all_cases_whole_period_statistics.csv"), index=False)

    # EC whole-period PDFs per case
    for base_label, base_wp in ec_wp.items():
        if not base_wp:
            continue
        pdf_path = os.path.join(ec_wp_dir, f"EC_{base_label}_WholePeriod_Full_Report.pdf")
        with PdfPages(pdf_path) as pdf:
            wp_helpers.ec_wp_combined_stats_page(pdf, base_wp, base_label, title_suffix=" (Daily & Monthly)")
            for station, wp in base_wp.items():
                wp_helpers.ec_wp_cover(pdf, station, base_label, wp)
                wp_helpers.ec_wp_stats_page(pdf, station, wp["stats_daily"], wp["stats_monthly"], " (Daily & Monthly)")
                wp_helpers.ec_wp_monthly_page(pdf, station, wp)
                wp_helpers.ec_wp_daily_page(pdf, station, wp)
        log(f"  -> {os.path.basename(pdf_path)}")

    # timeseries computed vs target (EC)
    ts_dir = os.path.join(ec_wp_dir, "timeseries_computed_vs_target")
    os.makedirs(ts_dir, exist_ok=True)
    base_infile = {s[0]: s[1] for s in studies}
    predictor_monthly = {}
    for base_label in ec_wp:
        in_file = base_infile.get(base_label)
        if in_file is None:
            predictor_monthly[base_label] = None
            continue
        _dfin = pd.read_csv(os.path.join(path_data, in_file), index_col=0, parse_dates=True)
        predictor_monthly[base_label] = _dfin.resample("ME").mean()

    combined_daily = []; combined_monthly = []
    for base_label in ec_wp:
        for station, wp in ec_wp[base_label].items():
            d = wp["daily_full"]; m = wp["monthly_full"]
            dsm2, ann = wp["dsm2_col"], wp["ann_col"]
            d_out = pd.DataFrame({"Date": d.index,
                                  "Target_DSM2": d[dsm2].values,
                                  "Computed_ANN": d[ann].values})
            d_out["Residual_ANN_minus_DSM2"] = d_out["Computed_ANN"] - d_out["Target_DSM2"]
            d_out.to_csv(os.path.join(ts_dir, f"EC_{base_label}_{station}_daily_computed_vs_target.csv"), index=False)
            m_out = pd.DataFrame({"Date": m.index,
                                  "Target_DSM2": m[dsm2].values,
                                  "Computed_ANN": m[ann].values})
            m_out["Residual_ANN_minus_DSM2"] = m_out["Computed_ANN"] - m_out["Target_DSM2"]
            pm = predictor_monthly.get(base_label)
            if pm is not None:
                pm_aligned = pm.reindex(m.index)
                for col in pm.columns:
                    m_out[col] = pm_aligned[col].values
            m_out.to_csv(os.path.join(ts_dir, f"EC_{base_label}_{station}_monthly_computed_vs_target.csv"), index=False)
            dL = d_out.copy(); dL.insert(0, "Station", station); dL.insert(0, "Base", base_label); combined_daily.append(dL)
            mL = m_out.copy(); mL.insert(0, "Station", station); mL.insert(0, "Base", base_label); combined_monthly.append(mL)
    if combined_daily:
        pd.concat(combined_daily, ignore_index=True).to_csv(
            os.path.join(ts_dir, "EC_ALL_cases_ALL_stations_daily_computed_vs_target.csv"), index=False)
    if combined_monthly:
        pd.concat(combined_monthly, ignore_index=True).to_csv(
            os.path.join(ts_dir, "EC_ALL_cases_ALL_stations_monthly_computed_vs_target.csv"), index=False)
    log(f"EC timeseries CSVs -> {ts_dir}")

    # EC monthly boxplots per station per base
    box_dir = os.path.join(ec_wp_dir, "boxplots_monthly_EC")
    resid_box_dir = os.path.join(ec_wp_dir, "boxplots_monthly_EC_residuals")
    os.makedirs(box_dir, exist_ok=True); os.makedirs(resid_box_dir, exist_ok=True)
    MONTH_LABELS = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    def _by_month(series):
        s = series.dropna()
        return [s[s.index.month == mo].values for mo in range(1, 13)]

    for base_label in ec_wp:
        pdf_path = os.path.join(box_dir, f"EC_{base_label}_monthly_boxplots.pdf")
        with PdfPages(pdf_path) as pdf:
            for station, wp in ec_wp[base_label].items():
                m = wp["monthly_full"]; dsm2, ann = wp["dsm2_col"], wp["ann_col"]
                fig, ax = plt.subplots(figsize=(11, 5.5))
                pos = np.arange(1, 13); w = 0.35
                bp1 = ax.boxplot(_by_month(m[dsm2]), positions=pos - w/2, widths=w, patch_artist=True,
                                 boxprops=dict(facecolor="#4C72B0", alpha=0.7), medianprops=dict(color="black"))
                bp2 = ax.boxplot(_by_month(m[ann]), positions=pos + w/2, widths=w, patch_artist=True,
                                 boxprops=dict(facecolor="#DD8452", alpha=0.7), medianprops=dict(color="black"))
                ax.set_xticks(pos); ax.set_xticklabels(MONTH_LABELS)
                ax.set_title(f"Monthly EC — {station} — {base_label}")
                ax.set_ylabel(f"Monthly EC ({UNIT_LABEL})"); ax.grid(True, axis="y", ls="--", alpha=0.4)
                ax.legend([bp1["boxes"][0], bp2["boxes"][0]], ["Target (DSM2)", "Computed (ANN)"])
                fig.tight_layout(); pdf.savefig(fig, bbox_inches="tight"); plt.close(fig)
        pdf_path = os.path.join(resid_box_dir, f"EC_{base_label}_monthly_residual_boxplots.pdf")
        with PdfPages(pdf_path) as pdf:
            for station, wp in ec_wp[base_label].items():
                m = wp["monthly_full"]
                resid = m[wp["ann_col"]] - m[wp["dsm2_col"]]
                fig, ax = plt.subplots(figsize=(11, 5.5))
                pos = np.arange(1, 13)
                ax.boxplot(_by_month(resid), positions=pos, widths=0.55, patch_artist=True,
                           boxprops=dict(facecolor="#55A868", alpha=0.7), medianprops=dict(color="black"))
                ax.axhline(0, color="red", ls="--")
                ax.set_xticks(pos); ax.set_xticklabels(MONTH_LABELS)
                ax.set_title(f"Monthly Residual — {station} — {base_label}")
                ax.set_ylabel(f"ANN − DSM2 ({UNIT_LABEL})"); ax.grid(True, axis="y", ls="--", alpha=0.4)
                fig.tight_layout(); pdf.savefig(fig, bbox_inches="tight"); plt.close(fig)
    log(f"EC boxplots -> {box_dir} and {resid_box_dir}")

    # =============================================================
    # PHASE 4: X2 whole-period
    # =============================================================
    log("\n" + "=" * 70)
    log("PHASE 4: X2 whole-period (1922–2021)")
    log("=" * 70)
    x2_wp_dir = out_dirs["x2_whole"]
    x2_wp = {}
    all_x2_wp_stats = []
    for base_label, r in x2_results.items():
        d_full = pd.concat([r["daily_train"], r["daily_test"]]).sort_index()
        d_full = d_full[~d_full.index.duplicated(keep="first")]
        m_full = d_full.resample("ME").mean().dropna()
        st_d = compute_stats(d_full["X2_DSM2"].values, d_full["X2_ANN_pred"].values)
        st_m = compute_stats(m_full["X2_DSM2"].values, m_full["X2_ANN_pred"].values)
        x2_wp[base_label] = dict(daily_full=d_full, monthly_full=m_full,
                                  stats_daily=st_d, stats_monthly=st_m,
                                  xscaler=r["xscaler"], yscaler=r["yscaler"])
        for scale, st in [("Daily", st_d), ("Monthly", st_m)]:
            if st:
                all_x2_wp_stats.append({"Base": base_label, "Period": "Whole (1922-2021)", "Scale": scale, **st})
    if all_x2_wp_stats:
        pd.DataFrame(all_x2_wp_stats).to_csv(
            os.path.join(x2_wp_dir, "X2_all_cases_whole_period_statistics.csv"), index=False)

    for base_label, wp in x2_wp.items():
        pdf_path = os.path.join(x2_wp_dir, f"X2_DIS_{base_label}_WholePeriod_Full_Report.pdf")
        with PdfPages(pdf_path) as pdf:
            wp_helpers.x2_wp_cover(pdf, base_label, wp)
            wp_helpers.x2_wp_stats_page(pdf, base_label, wp["stats_daily"], wp["stats_monthly"], " (Daily & Monthly)")
            wp_helpers.x2_wp_monthly_page(pdf, base_label, wp)
            wp_helpers.x2_wp_daily_page(pdf, base_label, wp)
        log(f"  -> {os.path.basename(pdf_path)}")

    # =============================================================
    # PHASE 5: Combined reports (all cases in single PDF)
    # =============================================================
    log("\n" + "=" * 70)
    log("PHASE 5: Combined all-case PDFs")
    log("=" * 70)

    # EC combined
    ec_combo_dir = out_dirs["ec_combo"]
    r1 = os.path.join(ec_combo_dir, "EC_AllCases_WholePeriod_Full_Report.pdf")
    with PdfPages(r1) as pdf:
        for base_label, base_wp in ec_wp.items():
            if not base_wp:
                continue
            wp_helpers.ec_wp_combined_stats_page(pdf, base_wp, base_label, title_suffix=" (Daily & Monthly)")
            for station, wp in base_wp.items():
                wp_helpers.ec_wp_cover(pdf, station, base_label, wp)
                wp_helpers.ec_wp_stats_page(pdf, station, wp["stats_daily"], wp["stats_monthly"], " (Daily & Monthly)")
                wp_helpers.ec_wp_monthly_page(pdf, station, wp)
                wp_helpers.ec_wp_daily_page(pdf, station, wp)
    log(f"  -> {os.path.basename(r1)}")

    r2 = os.path.join(ec_combo_dir, "EC_AllCases_WholePeriod_Monthly_Report.pdf")
    with PdfPages(r2) as pdf:
        for base_label, base_wp in ec_wp.items():
            if not base_wp:
                continue
            wp_helpers.ec_wp_combined_stats_page(pdf, base_wp, base_label,
                                                 scale_filter="Monthly", title_suffix=" (Monthly)")
            for station, wp in base_wp.items():
                wp_helpers.ec_wp_cover(pdf, station, base_label, wp)
                wp_helpers.ec_wp_stats_page(pdf, station, {}, wp["stats_monthly"], " (Monthly)")
                wp_helpers.ec_wp_monthly_page(pdf, station, wp)
    log(f"  -> {os.path.basename(r2)}")

    # X2 combined
    x2_combo_dir = out_dirs["x2_combo"]
    r3 = os.path.join(x2_combo_dir, "X2_AllCases_WholePeriod_Full_Report.pdf")
    with PdfPages(r3) as pdf:
        for base_label, wp in x2_wp.items():
            wp_helpers.x2_wp_cover(pdf, base_label, wp)
            wp_helpers.x2_wp_stats_page(pdf, base_label, wp["stats_daily"], wp["stats_monthly"], " (Daily & Monthly)")
            wp_helpers.x2_wp_monthly_page(pdf, base_label, wp)
            wp_helpers.x2_wp_daily_page(pdf, base_label, wp)
    log(f"  -> {os.path.basename(r3)}")

    r4 = os.path.join(x2_combo_dir, "X2_AllCases_WholePeriod_Monthly_Report.pdf")
    with PdfPages(r4) as pdf:
        for base_label, wp in x2_wp.items():
            wp_helpers.x2_wp_cover(pdf, base_label, wp, subtitle_extra=" (Monthly)")
            wp_helpers.x2_wp_stats_page(pdf, base_label, {}, wp["stats_monthly"], " (Monthly)")
            wp_helpers.x2_wp_monthly_page(pdf, base_label, wp)
    log(f"  -> {os.path.basename(r4)}")

    log("\n" + "=" * 70)
    log(f"ALL DONE. {len(studies)} studies processed. Results in: {output_base}")
    log("=" * 70)
    os.chdir(original_cwd)


# ===========================================================================
# GUI
# ===========================================================================
class AnnAnalysisGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("ANN Statistical Analysis — Automation GUI")
        self.geometry("1100x760")

        self.log_queue: "queue.Queue[str]" = queue.Queue()
        self.study_rows: list[dict] = []

        self._build_ui()
        self._poll_log_queue()

    # ---- UI ----------------------------------------------------
    def _build_ui(self):
        pad = dict(padx=6, pady=4)

        # --- Directories frame ---
        dir_frame = ttk.LabelFrame(self, text="Directories")
        dir_frame.pack(fill="x", padx=8, pady=6)

        ttk.Label(dir_frame, text="Data folder (path_data):").grid(row=0, column=0, sticky="w", **pad)
        self.var_data = tk.StringVar(value=DEFAULT_DATA_DIR)
        ttk.Entry(dir_frame, textvariable=self.var_data, width=100).grid(row=0, column=1, sticky="we", **pad)
        ttk.Button(dir_frame, text="Browse…", command=self._browse_data).grid(row=0, column=2, **pad)

        ttk.Label(dir_frame, text="Output folder (output_dir):").grid(row=1, column=0, sticky="w", **pad)
        self.var_out = tk.StringVar(value=DEFAULT_OUTPUT_DIR)
        ttk.Entry(dir_frame, textvariable=self.var_out, width=100).grid(row=1, column=1, sticky="we", **pad)
        ttk.Button(dir_frame, text="Browse…", command=self._browse_out).grid(row=1, column=2, **pad)

        dir_frame.columnconfigure(1, weight=1)

        # --- EC stations frame ---
        stn_frame = ttk.LabelFrame(self, text="EC stations (comma-separated)")
        stn_frame.pack(fill="x", padx=8, pady=6)
        self.var_stations = tk.StringVar(value=", ".join(DEFAULT_EC_STATIONS))
        ttk.Entry(stn_frame, textvariable=self.var_stations).pack(fill="x", padx=6, pady=4)

        # --- Studies table frame ---
        studies_frame = ttk.LabelFrame(
            self, text="Studies (add / remove rows — supports any number of studies)")
        studies_frame.pack(fill="both", expand=True, padx=8, pady=6)

        header = ttk.Frame(studies_frame)
        header.pack(fill="x")
        headers = ["Label", "EC input CSV", "EC output CSV",
                   "X2 input CSV", "X2 output CSV", ""]
        widths  = [18, 22, 22, 22, 22, 4]
        for i, (h, w) in enumerate(zip(headers, widths)):
            ttk.Label(header, text=h, width=w, anchor="w",
                      font=("Segoe UI", 9, "bold")).grid(row=0, column=i, padx=2, pady=2)

        # scrollable canvas for rows
        canvas = tk.Canvas(studies_frame, highlightthickness=0)
        canvas.pack(side="left", fill="both", expand=True)
        sb = ttk.Scrollbar(studies_frame, orient="vertical", command=canvas.yview)
        sb.pack(side="right", fill="y")
        canvas.configure(yscrollcommand=sb.set)

        self.rows_container = ttk.Frame(canvas)
        canvas.create_window((0, 0), window=self.rows_container, anchor="nw")
        self.rows_container.bind(
            "<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))

        # add default studies
        for s in DEFAULT_STUDIES:
            self._add_study_row(*s)

        # buttons
        btns = ttk.Frame(self)
        btns.pack(fill="x", padx=8, pady=4)
        ttk.Button(btns, text="+ Add study", command=lambda: self._add_study_row()).pack(side="left", padx=4)
        ttk.Button(btns, text="Clear all", command=self._clear_rows).pack(side="left", padx=4)
        ttk.Button(btns, text="Reset defaults", command=self._reset_defaults).pack(side="left", padx=4)
        self.btn_run = ttk.Button(btns, text="▶  Run Analysis", command=self._on_run)
        self.btn_run.pack(side="right", padx=4)

        # --- Log frame ---
        log_frame = ttk.LabelFrame(self, text="Log")
        log_frame.pack(fill="both", expand=True, padx=8, pady=6)
        self.txt_log = tk.Text(log_frame, height=14, wrap="none",
                               font=("Consolas", 9), bg="#111", fg="#ddd")
        self.txt_log.pack(side="left", fill="both", expand=True)
        sb2 = ttk.Scrollbar(log_frame, orient="vertical", command=self.txt_log.yview)
        sb2.pack(side="right", fill="y")
        self.txt_log.configure(yscrollcommand=sb2.set)

    def _add_study_row(self, label="", ec_in="", ec_out="", x2_in="", x2_out=""):
        row = ttk.Frame(self.rows_container)
        row.pack(fill="x", pady=1)
        vars_ = [tk.StringVar(value=v) for v in (label, ec_in, ec_out, x2_in, x2_out)]
        widths = [18, 22, 22, 22, 22]
        for i, (v, w) in enumerate(zip(vars_, widths)):
            ttk.Entry(row, textvariable=v, width=w).grid(row=0, column=i, padx=2, pady=1)
        btn = ttk.Button(row, text="×", width=3,
                         command=lambda: self._remove_row(row_dict))
        btn.grid(row=0, column=5, padx=2, pady=1)
        row_dict = {"frame": row, "vars": vars_}
        self.study_rows.append(row_dict)

    def _remove_row(self, row_dict):
        row_dict["frame"].destroy()
        self.study_rows.remove(row_dict)

    def _clear_rows(self):
        for r in list(self.study_rows):
            self._remove_row(r)

    def _reset_defaults(self):
        self._clear_rows()
        for s in DEFAULT_STUDIES:
            self._add_study_row(*s)
        self.var_data.set(DEFAULT_DATA_DIR)
        self.var_out.set(DEFAULT_OUTPUT_DIR)
        self.var_stations.set(", ".join(DEFAULT_EC_STATIONS))

    def _browse_data(self):
        d = filedialog.askdirectory(initialdir=self.var_data.get() or os.getcwd(),
                                    title="Select data folder")
        if d:
            self.var_data.set(d)

    def _browse_out(self):
        d = filedialog.askdirectory(initialdir=self.var_out.get() or os.getcwd(),
                                    title="Select output folder")
        if d:
            self.var_out.set(d)

    # ---- Run ---------------------------------------------------
    def _collect_studies(self):
        studies = []
        for r in self.study_rows:
            vals = [v.get().strip() for v in r["vars"]]
            if not any(vals):
                continue
            if not all(vals):
                raise ValueError(f"Incomplete study row: {vals}")
            studies.append(tuple(vals))
        return studies

    def _on_run(self):
        try:
            path_data = self.var_data.get().strip()
            output_base = self.var_out.get().strip()
            if not path_data or not os.path.isdir(path_data):
                messagebox.showerror("Error", "Data folder does not exist.")
                return
            if not output_base:
                messagebox.showerror("Error", "Output folder is required.")
                return
            stations = [s.strip() for s in self.var_stations.get().split(",") if s.strip()]
            if not stations:
                messagebox.showerror("Error", "At least one EC station is required.")
                return
            studies = self._collect_studies()
            if not studies:
                messagebox.showerror("Error", "At least one study is required.")
                return
        except Exception as e:
            messagebox.showerror("Error", str(e))
            return

        os.makedirs(output_base, exist_ok=True)
        self.btn_run.configure(state="disabled")
        self._log(f"Starting analysis: {len(studies)} studies, {len(stations)} EC stations")
        t = threading.Thread(target=self._worker,
                             args=(path_data, output_base, studies, stations),
                             daemon=True)
        t.start()

    def _worker(self, path_data, output_base, studies, stations):
        try:
            run_pipeline(path_data, output_base, studies, stations, self._log)
            self._log("\n✓ Pipeline finished successfully.")
        except Exception:
            self._log("\n✗ ERROR:")
            self._log(traceback.format_exc())
        finally:
            self.after(0, lambda: self.btn_run.configure(state="normal"))

    # ---- Logging (thread-safe) ---------------------------------
    def _log(self, msg: str):
        self.log_queue.put(str(msg))

    def _poll_log_queue(self):
        try:
            while True:
                msg = self.log_queue.get_nowait()
                self.txt_log.insert("end", msg + "\n")
                self.txt_log.see("end")
        except queue.Empty:
            pass
        self.after(120, self._poll_log_queue)


def main():
    app = AnnAnalysisGUI()
    app.mainloop()


if __name__ == "__main__":
    main()
