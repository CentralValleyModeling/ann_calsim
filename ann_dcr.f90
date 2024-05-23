! Generated from 'ann.f90.template'
! Last change: RW Feb 8,2003, Shengjun 5/2/2006
module ann
  integer :: ndays = 8, nweeks=10 !shengjun:
                                  !ndays: number of daily input including today; 
                                  !nweeks: number of period averages
  integer :: daysInOneAverage =11 !3/22/2006: number of days in one period average
     
  real :: scalingLow=0.1, scalingHigh=0.9 !3/23/2006
       
    !Input scaling factors: x2 ANN will have a different input scaling                       
    real ::     DXC_SCALE = 0.80000000,   DXC_OFFSET = 0.10000000
    real ::     EXP_SCALE = 0.0.0000607727573,   EXP_OFFSET = 0.04339446
    real ::     SAC_SCALE = 0.0000032086525,   SAC_OFFSET = 0.08503035
    real ::     SJR_SCALE = 0.0000152175274,   SJR_OFFSET = 0.09179344
    real ::     SFtide_SCALE = 0.132676578, SFtide_OFFSET = -0.31441527
    real ::     DICU_SCALE = 0.0000983075516, DICU_OFFSET = 0.5882375
    real ::     VernEC_SCALE = 0.80000000, VernEC_OFFSET = 0.10000000 
    

    !Output scaling factors
    real ::        jpt_scale = 0.00019296,      jpt_OFFSET = 0.0997774  ! 
    real ::      orrsl_scale = 0.00047326,    orrsl_OFFSET = 0.09720651 ! 
    real ::        emm_scale = 0.00012933,      emm_OFFSET = 0.09994794 ! 
    real ::    antioch_scale = 0.0000764044, antioch_OFFSET = 0.0999732317 ! 
    real ::    collins_scale = 0.0000532275665, collins_OFFSET = 0.099888 ! 
    real ::    mallard_scale = 0.00004434, mallard_OFFSET = 0.09274145  !
    real :: losvaqueros_scale = 0.00065188, losvaqueros_OFFSET = 0.03406080 ! 
    ! start of add 7/1/07 swu
    real :: ccfb_scale = 0.00072282, ccfb_OFFSET = 0.09405423 !  real :: ccfb_scale = 0.00029679, ccfb_OFFSET = 0.367411 !
    real :: CCFBintake_scale = 0.0007228172, CCFBintake_OFFSET = 0.0940542313 
    real :: middleriver_scale = 0.00087014, middleriver_OFFSET = 0.09613255 ! 
    real :: VICTintake_scale  = 0.0008482962, VICTintake_OFFSET = 0.0918290290 ! 
    real :: CVPintake_scale  = 0.00070461, CVPintake_OFFSET =0.09578942 ! 
    real :: x2_scale = 0.0163743169, X2_OFFSET = -0.6832326995 
    real :: beldan_scale = 0.0000412348, beldan_offset = 0.0998171911
    real :: MTZ_scale = 0.0000289906, MTZ_offset = 0.0868548530 
    !end of add         
     
  logical :: init_called = .false.
  !real, dimension(7*nweeks+ndays) :: inarray
  !real, dimension(:),allocatable :: inarray !allocatable array will not be recognized by VB
  !real, dimension(:),allocatable  :: outarray !allocatable array will not be recognized by VB so commented
  real, dimension(126) :: inarray !shengjun add: because VB can not recognize Fortran allocatable array & revised by Hao in 9/2008 
  real, dimension(54) :: inarrayX2
  real, dimension(1) :: outarray!shengjun add: because VB can not recognize Fortran allocatable array
    
  type inputStatus !shengjun 3/23/2006
    !any variable return TRUE means going out of range
    logical OutOfBound
    logical DXCscaled, ExportScaled, NorthScaled,SouthScaled,SFtideScaled,DICUscaled, VernECscaled    !revised by Hao in 9/2008
    
  end type inputStatus

  type (inputStatus),public :: TodayInputStatus !record the input range for today's EC simulation
  type (inputStatus),public :: currMonthInputStatus !record the input range for current month's EC simulation  
contains
  function scaleAndCopyDaily( inputvalues, inarray_offset, a, b) !return TRUE or FALSE to indicate if the scaled input go out of range
    real, dimension(118), intent(in) :: inputvalues
    !  real, dimension(:), intent(inout) :: inarray
    integer, intent(in) :: inarray_offset
    real, intent(in) :: a,b
    integer :: i,j
    real :: sum      
    
    scaleAndCopyDaily=.FALSE. !3/23/2006
    
    do i=1,ndays
       inarray(i+inarray_offset) = a*inputvalues(1+ndays+nweeks*daysInOneAverage-i)+b
       
!       if(inarray(i+inarray_offset)< (scalingLow-0.01) .or. inarray(i+inarray_offset) > (scalingHigh+0.01)) then!3/23/2006
 !        scaleAndCopyDaily = .TRUE.
  !       print *,"(1) out of bound with scaled value: inputvalues, inarray_offset, a, b ",inarray(i+inarray_offset), inputvalues, inarray_offset, a, b
   !      stop
    !   end if
         
    end do

    do i=1,nweeks
       sum = 0.0
       do j=1,daysInOneAverage
          sum = sum + a*inputvalues(((nweeks-i+1)*daysInOneAverage)-j+1)+b
       end do
       
       inarray(i+inarray_offset+ndays) = sum/daysInOneAverage
       
!       if(inarray(i+inarray_offset+ndays)< (scalingLow-0.01) .or. inarray(i+inarray_offset+ndays) > (scalingHigh+0.01)) then !3/23/2006
 !        scaleAndCopyDaily = .TRUE.
  !       print *,"(2) out of bound with scaled value: inputvalues, inarray_offset, a, b ",inarray(i+inarray_offset+ndays), inputvalues, inarray_offset, a, b
   !      stop
    !   end if
       
    end do
  end function scaleAndCopyDaily
  
  !
  ! CalcDaily determines the salinity on a daily basis when provided with vectors of
  ! flow history for the specified location.
  ! location = 1: jersey point
  !            2: contra costa canal
  !            3: emmaton
  !            4: antioch
  !            5: collins
  !            6: mallard (chipps island)
  !            7: Los Vaqueros
  function calcdaily(sac,sjr,export,currSFtide,DICU,dxc,VernEC,location)!shengjun 12/16/2004 and 2/25/2005
    use fnet_orrsl
    use fnet_jp
    use fnet_emm
    use fnet_antioch
    use fnet_CO
    use fnet_mallard
    use fnet_LosVaqueros !shengjun 4/26/2005
    use fnet_CCFB  !swu 7/1/07
    use fnet_CCFB_intake
    use fnet_MidR_intake
    use fnet_Victoria_intake
    use fnet_CVP_intake
    use fnet_X2
    use fnet_beldan
    use fnet_MTZ	
    
    real, dimension(118), intent(in) :: sac,sjr,export,dxc,currSFtide, DICU, VernEC
    real, dimension(118) :: NDO, GEC,g !shengjun add 8/5/2004
    integer, intent(in) :: location
    integer :: ANNengineStatus =0
    real :: calcdaily    

    TodayInputStatus=inputStatus(.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.)   !9/2008

    !start of add 7/1/2007
    !if (location == 13) then !use the same 6 input names but different meaning, make sure the order is the same of ANN input
        !matlab ANN scaling:
        !dcc a: 0.8
        !dcc b: 0.1
        !Delta_outflow a: 1.3946e-006
        !Delta_outflow b: 0.17865
        !sac a: 2.3478e-006
        !sac b: 0.10064
        !InDeltaFlows a: 1.1573e-005
        !InDeltaFlows b: 0.093527
       ! SF tide a: 0.13652
        !SF tide b: -0.34642
        !dicu a: 5.4459e-005
        !dicu b: 0.58033
      
        !EXP_SCALE = 1.3946e-006;   EXP_OFFSET = 0.17865
        !SAC_SCALE = 2.3478e-006;   SAC_OFFSET = 0.10064
        !SJR_SCALE = 1.1573e-005;   SJR_OFFSET = 0.093527
        
	
	    !EXP_SCALE = 0.00000174; EXP_OFFSET = 0.09824292;
	    !SAC_SCALE = 0.00000256; SAC_OFFSET = 0.10041563;
	    !SJR_SCALE = 0.00001176; SJR_OFFSET = 0.09260526;
	   
    !else        
        EXP_SCALE = 0.0.0000607727573;   EXP_OFFSET = 0.04339446;
        SAC_SCALE = 0.0000032086525;   SAC_OFFSET = 0.08503035;
        
		!SJR_SCALE = 0.00001432;   SJR_OFFSET = 0.09126775;
    !end if
    !end of add         

    !shengjun 3/23/2006
    TodayInputStatus.DXCscaled=scaleAndCopyDaily(dxc,0 ,dxc_scale,dxc_offset)  
    TodayInputStatus.ExportScaled=scaleAndCopyDaily(export,18,exp_scale,exp_offset)
    TodayInputStatus.NorthScaled=scaleAndCopyDaily(sac,36,sac_scale,sac_offset)
    TodayInputStatus.SouthScaled=scaleAndCopyDaily(sjr,54,sjr_scale,sjr_offset)
    TodayInputStatus.SFtideScaled=scaleAndCopyDaily(currSFtide,72,SFtide_scale,SFtide_offset)!shengjun
    TodayInputStatus.DICUscaled= scaleAndCopyDaily(DICU,90,DICU_scale,DICU_offset)
    TodayInputStatus.VernECscaled= scaleAndCopyDaily(VernEC,108,VernEC_scale,VernEC_offset)  !Hao 9/2008
    
    if( TodayInputStatus.DXCscaled .or. &
        TodayInputStatus.ExportScaled .or. &
        TodayInputStatus.NorthScaled .or. &
        TodayInputStatus.SouthScaled .or. &
        TodayInputStatus.SFtideScaled .or. &
        TodayInputStatus.DICUScaled .or. &
        TodayInputStatus.VernECscaled) then        !9/2008
        
        TodayInputStatus.OutOfBound=.TRUE.
        currMonthInputStatus = TodayInputStatus !3/24/2006
!        print *,"out of bound"
     end if            
     !end shengjun 3/23/2006
        
    if (location == 1) then ! jersey point 
       call fnet_jp_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-jpt_offset)/jpt_scale;
    else if (location == 2) then ! contra costa canal
       call fnet_orrsl_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-orrsl_offset)/orrsl_scale;
    else if (location == 3) then ! emmaton
       call fnet_emm_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-emm_offset)/emm_scale;
    else if (location == 4) then ! antioch
       call fnet_antioch_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-antioch_offset)/antioch_scale;       
    else if (location == 5) then ! collins
       call fnet_CO_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-collins_offset)/collins_scale;
    else if (location == 6) then ! mallard (chipps island)
       call fnet_mallard_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-mallard_offset)/mallard_scale;
    else if (location == 7) then ! Los Vaqueros
       call fnet_LosVaqueros_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-losvaqueros_offset)/losvaqueros_scale;    
    else if (location == 8) then ! start of add 7/1/07 swu
       call fnet_MidR_intake_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-middleriver_offset)/middleriver_scale;    
    else if (location == 9) then 
       call fnet_Victoria_intake_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-VICTintake_offset)/VICTintake_scale;    
    else if (location == 10) then
       call fnet_CVP_intake_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-cvpintake_offset)/cvpintake_scale;    
    else if (location == 11) then 
       call fnet_CCFB_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-CCFB_offset)/CCFB_scale;    
    else if (location == 12) then
       call fnet_CCFB_intake_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-CCFBintake_offset)/ccfbintake_scale;    
    !else if (location == 13) then 
       !call fnet_X2_engine(inarray,outarray,ANNengineStatus)
       !calcdaily =(outarray(1)-X2_offset)/x2_scale;    
    else if (location == 20) then ! Belden landing
       call fnet_beldan_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-beldan_offset)/beldan_scale;                
    else if (location == 21) then ! Martinez NJ 9/16/2020
       call fnet_MTZ_engine(inarray,outarray,ANNengineStatus)
       calcdaily =(outarray(1)-MTZ_offset)/MTZ_scale;                
    else       
       print *, "Wrong EC station specified. ", location
       stop   
    end if
        
    if(calcdaily < 0.0) calcdaily=0.0 !shengjun 5/9/2006
    
  end function calcdaily

  function scaleAndCopyDailyX2( inputvalues, inarray_offset, a, b) !return TRUE or FALSE to indicate if the scaled input go out of range
    real, dimension(118), intent(in) :: inputvalues
    !  real, dimension(:), intent(inout) :: inarrayX2
    integer, intent(in) :: inarray_offset
    real, intent(in) :: a,b
    integer :: i,j
    real :: sum      
    
    scaleAndCopyDailyX2=.FALSE. !3/23/2006
    
    do i=1,ndays 
       inarrayX2(i+inarray_offset) = a*inputvalues(1+ndays+nweeks*daysInOneAverage-i)+b
       
!       if(inarrayX2(i+inarray_offset)< (scalingLow-0.01) .or. inarrayX2(i+inarray_offset) > (scalingHigh+0.01)) then!3/23/2006
 !        scaleAndCopyDaily = .TRUE.
  !       print *,"(1) out of bound with scaled value: inputvalues, inarray_offset, a, b ",inarrayX2(i+inarray_offset), inputvalues, inarray_offset, a, b
   !      stop
    !   end if
         
    end do

    do i=1,nweeks
       sum = 0.0
       do j=1,daysInOneAverage
          sum = sum + a*inputvalues(((nweeks-i+1)*daysInOneAverage)-j+1)+b
       end do
       
       inarrayX2(i+inarray_offset+ndays) = sum/daysInOneAverage
       
!       if(inarrayX2(i+inarray_offset+ndays)< (scalingLow-0.01) .or. inarrayX2(i+inarray_offset+ndays) > (scalingHigh+0.01)) then !3/23/2006
 !        scaleAndCopyDaily = .TRUE.
  !       print *,"(2) out of bound with scaled value: inputvalues, inarray_offset, a, b ",inarrayX2(i+inarray_offset+ndays), inputvalues, inarray_offset, a, b
   !      stop
    !   end if
       
    end do
  end function scaleAndCopyDailyX2
  
  function calcX2daily(sac,export,currSFtide,location)!Hao Mar 2009
    use fnet_orrsl
    use fnet_jp
    use fnet_emm
    use fnet_antioch
    use fnet_CO
    use fnet_mallard
    use fnet_LosVaqueros !shengjun 4/26/2005
    use fnet_CCFB  !swu 7/1/07
    use fnet_CCFB_intake
    use fnet_MidR_intake
    use fnet_Victoria_intake
    use fnet_CVP_intake
    use fnet_X2
    
    real, dimension(118), intent(in) :: sac,export,currSFtide
    real, dimension(118) :: NDO, GEC,g 
    integer, intent(in) :: location
    integer :: ANNengineStatus =0
    real :: calcX2daily    

    TodayInputStatus=inputStatus(.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.)   !9/2008

    !start of add 7/1/2007
    if (location == 13) then !use the same 6 input names but different meaning, make sure the order is the same of ANN input
        !matlab ANN scaling:
        !dcc a: 0.8
        !dcc b: 0.1
        !Delta_outflow a: 1.3946e-006
        !Delta_outflow b: 0.17865
        !sac a: 2.3478e-006
        !sac b: 0.10064
        !InDeltaFlows a: 1.1573e-005
        !InDeltaFlows b: 0.093527
       ! SF tide a: 0.13652
        !SF tide b: -0.34642
        !dicu a: 5.4459e-005
        !dicu b: 0.58033
      
        !EXP_SCALE = 1.3946e-006;   EXP_OFFSET = 0.17865
        !SAC_SCALE = 2.3478e-006;   SAC_OFFSET = 0.10064
        !SJR_SCALE = 1.1573e-005;   SJR_OFFSET = 0.093527
        
	
        EXP_SCALE = 0.0000027867; EXP_OFFSET = 0.0934011614;     ! Delta_outflow
		SAC_SCALE = 0.80000000; SAC_OFFSET = 0.10000000;    ! X2_31day_prv
	   
    end if
    !end of add         

    !shengjun 3/23/2006
    TodayInputStatus.DXCscaled=.FALSE.  
    TodayInputStatus.ExportScaled=scaleAndCopyDailyX2(export,0,exp_scale,exp_offset)
    TodayInputStatus.NorthScaled=scaleAndCopyDailyX2(sac,18,sac_scale,sac_offset)
    TodayInputStatus.SouthScaled=.FALSE.  
    TodayInputStatus.SFtideScaled=scaleAndCopyDailyX2(currSFtide,36,SFtide_scale,SFtide_offset)
    TodayInputStatus.DICUscaled= .FALSE.  
    TodayInputStatus.VernECscaled= .FALSE.   !Hao 9/2008
    
    if( TodayInputStatus.DXCscaled .or. &
        TodayInputStatus.ExportScaled .or. &
        TodayInputStatus.NorthScaled .or. &
        TodayInputStatus.SouthScaled .or. &
        TodayInputStatus.SFtideScaled .or. &
        TodayInputStatus.DICUScaled .or. &
        TodayInputStatus.VernECscaled) then        !9/2008
        
        TodayInputStatus.OutOfBound=.TRUE.
        currMonthInputStatus = TodayInputStatus !3/24/2006
!        print *,"out of bound"
     end if            
     !end shengjun 3/23/2006
        
    if (location == 13) then  
       call fnet_X2_engine(inarrayX2,outarray,ANNengineStatus)
       calcX2daily =(outarray(1)-X2_offset)/x2_scale;    
     !end of add         
    else
       print *, "Wrong X2 station specified."
       stop   
    end if
        
    if(calcX2daily < 0.0) calcX2daily=0.0 !shengjun 5/9/2006
    
  end function calcX2daily  
  
end module ann
