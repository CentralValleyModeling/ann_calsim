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
    NDOI = add_pathnames(dssfile, ['/CALSIM-SMOOTH/NDOI/FLOW//1DAY/L2020A_DCP_NAA_2040SLR10/'])
    smscg = add_pathnames(dssfile, ['/CALSIM/SMSCG_OP/GATE-OP-RATIO//1MON/L2020A_DCP_NAA_2040SLR10/'])
    tide = add_pathnames(dssfile, ['/DWR/SAN_FRANCISCO/STAGE-MAX-MIN//1DAY/ASTRO_NAVD_20170607/'])
    df=pd.concat([NDOI,smscg,tide],axis=1,join='inner')
    df.columns=['NDOI','smscg','tide']
    return df

