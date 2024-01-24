#
import pyhecdss
import pandas as pd
import numpy as np

def add_pathnames(dssfile, paths):
    '''
    add the pathnames in the given HEC-DSS file and return the resulting dataframe
    '''
    sum = 0
    for path in paths:
        df = list(pyhecdss.get_ts(dssfile, path))[0][0]
        # resample to daily, if daily this is no op
        df = df.resample('D').ffill()
        # then convert to time stamp
        if isinstance(df.index, pd.PeriodIndex):
            df.index = df.index.to_timestamp()
        sum = sum+df.iloc[:, 0]
    return sum


def collate_calsim_inputs_for_ann(dssfile):
    '''
    read inputs from given HEC-DSS File and has hardwired definitions of pathnames that have to be added to yield inputs

    Parameters
    ----------
    input HEC-DSS file with pathnames

    Returns
    ------
    returns a dataframe with named feature columns
    '''
    sac = add_pathnames(dssfile, ['/CALSIM-SMOOTH/C_SAC041/FLOW//1DAY/L2020A_CS3V27_BASE_NS/',
                                  '/CALSIM/C_CSL004A/CHANNEL//1MON/L2020A/',
                                  '/CALSIM/C_CLV004/FLOW//1MON/L2020A_CS3V27_BASE_NS/',
                                  '/CALSIM/C_MOK019/CHANNEL//1MON/L2020A/'])
    exports = add_pathnames(dssfile, ['/CALSIM/C_CAA003_TD/FLOW//1MON/L2020A_CS3V27_BASE_NS/',
                                      '/CALSIM/C_DMC000_TD/FLOW//1MON/L2020A_CS3V27_BASE_NS/',
                                      '/CALSIM/D408/FLOW//1MON/L2020A_CS3V27_BASE_NS/',
                                      '/CALSIM/D_SJR028_WTPDWS/FLOW//1MON/L2020A_CS3V27_BASE_NS/'])
    dcc=add_pathnames(dssfile, ['/CALSIM-PROCESSED/DCC/OP//IR-YEAR/L2020A_CS3V27_BASE_NS/'])
    net_dcd=add_pathnames(dssfile, ['/CALSIM/NET_DICU/DICU_FLOW//1MON/L2020A/'])
    sjr = add_pathnames(dssfile, ['/CALSIM-SMOOTH/C_SJR070/FLOW//1DAY/L2020A_CS3V27_BASE_NS/'])
    tide = add_pathnames(dssfile, ['/DWR/SAN_FRANCISCO/STAGE-MAX-MIN//1DAY/ASTRO_NAVD_20170607/'])
    smscg = add_pathnames(dssfile, ['/CALSIM/SMSCG_OP/GATE-OP-RATIO//1MON/L2020A_CS3V27_BASE_NS/'])
    df=pd.concat([dcc,exports,sac,sjr,tide,net_dcd,smscg],axis=1,join='inner')
    df.columns=['dcc','exports','sac','sjr','tide','net_dcd','smscg']
    return df

