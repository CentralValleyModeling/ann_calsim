module fnet_EMM

! a = 0.00014203
! b = 0.075691

intrinsic Reshape
real, dimension(8,126) :: input = &
  Reshape((/0.040997,-0.116227,-0.090387,-0.258615,0.221989,0.054271,0.144744,0.092239, &
            -0.155858,-0.043866,-0.008024,-0.368931,0.144216,-0.114903,0.074015,-0.296802, &
            -0.172454,-0.016350,0.060914,-0.197226,0.030570,-0.206530,0.004399,-0.333061, &
            -0.058389,0.011761,0.097655,0.029435,-0.061359,-0.094719,-0.083377,-0.162549, &
            0.026953,-0.017673,0.093857,-0.012884,-0.009434,0.040796,-0.150215,-0.019245, &
            0.302907,-0.072480,-0.081656,-0.041480,0.036074,-0.285276,0.073963,0.305755, &
            0.018647,-0.064505,0.094147,0.033140,-0.001200,-0.221502,-0.025886,0.100059, &
            0.053589,0.110050,0.020024,0.221451,-0.038365,-0.034537,0.042980,0.108006, &
            -0.549334,0.043009,0.289417,-0.036871,0.145711,-0.324681,0.118351,0.008825, &
            -0.029492,-0.097126,0.007354,0.014488,0.083698,-0.826403,0.342442,0.634862, &
            0.427038,0.163349,-0.254375,-0.212848,0.427907,-0.024621,0.340820,0.063781, &
            0.464499,-0.165593,-0.083177,-0.359908,0.073967,-0.248742,-0.161915,0.750263, &
            0.131642,0.041177,0.022402,-0.128700,-0.084510,-0.445793,-0.141366,-0.476173, &
            0.038717,-0.158064,0.014343,-0.154170,-0.115352,-0.581672,-0.177861,-1.277758, &
            -0.253500,0.095045,0.029012,-0.098708,-0.088235,-0.402338,0.092829,-0.279985, &
            0.061505,-0.235547,-0.059778,-0.274345,0.153213,-0.506514,0.162752,-0.482315, &
            0.192269,0.310248,0.055041,0.119077,0.301509,-0.140762,0.202033,-0.771666, &
            -0.009650,-0.164399,0.168330,-0.201025,0.146599,-0.210772,-0.013917,0.629932, &
            0.061926,0.029557,-0.148671,0.389214,0.208115,0.758395,0.274910,-0.238999, &
            -0.002791,-0.135653,0.042770,0.299530,0.147682,0.189304,0.413356,-0.050099, &
            0.104067,-0.148167,-0.040513,0.100291,0.000936,0.293884,0.164905,0.344029, &
            -0.072948,-0.142181,0.043884,0.135353,-0.024090,0.536085,0.181225,0.417217, &
            -0.158071,-0.085868,0.085168,-0.130859,-0.225838,0.075174,0.071612,0.168500, &
            0.077926,0.020438,0.190284,-0.236653,-0.095984,0.098374,-0.110551,0.264454, &
            -0.019134,-0.126879,0.170608,0.126639,-0.053846,0.280876,0.135251,-0.105860, &
            0.032617,-0.228604,0.180739,0.138193,-0.486677,0.016078,0.058568,-0.409448, &
            -0.120772,0.191539,0.460388,-0.045791,-0.305191,0.109551,0.265711,0.519429, &
            0.031502,-0.037355,0.287736,0.217185,-0.193013,0.617148,0.314283,0.618228, &
            -0.372196,-0.204357,0.398194,0.452648,0.027722,0.618273,0.381370,0.334452, &
            -0.206441,0.085385,0.311459,0.066273,-0.009947,0.654777,-0.058919,0.532388, &
            -0.218608,-0.267755,0.283362,0.188558,-0.024401,0.078712,-0.066434,-0.465326, &
            0.043371,0.033881,0.128463,0.363899,-0.194830,-0.458704,0.083266,-1.312177, &
            -0.055405,0.133953,0.062693,0.020793,0.115444,0.256727,0.027286,-0.666057, &
            0.095355,-0.015211,-0.021637,-0.240413,0.077606,-0.011087,-0.141217,-0.607075, &
            0.028086,-0.576737,0.162156,-0.027740,-0.167571,-0.221510,-0.233811,0.534861, &
            0.321115,0.114887,0.194504,0.307884,-0.215938,0.457095,-0.469908,1.243055, &
            -0.332438,4.049937,-2.888355,2.238746,2.791671,1.571834,-1.829945,1.814499, &
            -0.562034,4.215196,-2.703939,2.165060,2.670463,1.409858,-2.115515,2.159116, &
            -0.581836,4.137242,-2.842463,2.081085,2.642378,1.717936,-1.924215,2.143799, &
            -0.348630,4.079573,-2.646003,1.753212,2.538959,1.866025,-2.070463,1.580776, &
            -0.251844,4.157951,-2.720575,1.984595,2.567407,1.658708,-1.936277,1.891928, &
            -0.702639,4.210854,-2.861737,1.933113,2.592654,1.327745,-1.945318,1.980628, &
            -0.686431,4.306331,-2.913368,2.178429,2.841274,1.168571,-2.364528,2.044111, &
            -1.031801,4.544529,-3.152119,2.280391,2.910760,1.164425,-2.405163,2.205137, &
            -2.559890,5.183119,-4.419997,4.017272,4.044023,-0.872164,-3.749864,3.134081, &
            -2.041905,5.879598,-3.760599,3.898798,3.798137,-0.956494,-3.837168,2.291307, &
            -1.298792,5.851680,-2.847690,3.152125,2.644025,-0.869894,-2.823108,1.832054, &
            -0.488328,4.822752,-1.465788,1.377073,1.272037,0.156987,-1.771541,0.957710, &
            -0.493921,4.031610,-0.943598,0.605874,0.994429,0.119336,-1.304678,0.516534, &
            -0.683777,2.597082,-0.297961,-0.147807,0.407670,0.415014,-0.500755,-0.083400, &
            -0.812316,0.923540,-0.299730,-0.327346,0.349872,0.922853,-0.339177,0.195346, &
            -0.799864,0.962773,-0.086985,-0.106939,0.516168,0.868896,-0.196254,0.698358, &
            -0.479396,1.072264,0.059389,-0.209026,0.448993,0.839579,-0.194246,0.489011, &
            -0.315286,0.793600,-0.033384,-0.376150,0.695300,0.920146,-0.362927,0.967858, &
            0.059465,-0.190616,-0.414305,-0.169446,0.132751,0.857217,-0.080514,-0.477764, &
            0.318756,-0.030022,-0.302925,0.214406,0.373859,0.419478,-0.284634,-0.592706, &
            0.004973,0.143600,-0.207285,0.090864,0.241375,0.520716,-0.438577,-0.525449, &
            -0.262903,-0.082738,-0.620871,0.135051,0.427284,0.155891,-0.473176,-0.080827, &
            0.000679,-0.093641,-0.575660,0.125962,0.417191,0.182454,-0.656164,-0.118348, &
            -0.281979,0.305782,-0.572576,0.365833,0.685136,0.094735,-0.716247,-0.006209, &
            -0.081866,-0.082977,-0.726134,0.360821,0.548007,0.186744,-0.696231,0.003547, &
            -0.223006,0.026600,-0.758309,0.678173,0.740100,-0.259199,-0.765585,0.225355, &
            -0.103742,-0.270443,-0.355022,0.859139,0.268140,-0.115761,-0.545408,-0.561455, &
            -0.207214,0.261657,-0.769226,1.107074,0.829878,-0.484455,-0.768720,-0.194967, &
            0.217300,0.339304,-0.502710,0.671214,0.393473,-0.089398,-0.642276,-0.837871, &
            0.054471,0.865712,-0.240545,0.634007,0.447972,0.046604,-0.270334,-0.563114, &
            0.515454,0.389968,0.037372,0.350618,0.022410,0.639658,0.169315,-0.288270, &
            0.520167,0.940079,-0.036505,0.231704,0.190954,0.297098,-0.127392,0.365845, &
            0.195628,0.461902,0.029648,0.146780,0.148404,0.523471,-0.192808,0.248404, &
            0.291645,0.307545,0.065054,0.450941,0.004994,0.793759,-0.618852,0.047011, &
            0.335089,0.473465,0.269158,0.161603,0.190918,1.199756,-0.272892,0.033358, &
            -0.179632,0.552502,0.133994,0.272015,0.532266,0.950705,-0.197400,-0.016752, &
            0.445698,0.031233,0.261321,-0.351913,0.178304,-0.427194,0.122241,0.272919, &
            0.152618,0.080518,0.159840,-0.233314,0.124226,-0.404892,-0.089431,0.008291, &
            -0.073714,0.041499,-0.023393,-0.276702,0.032671,-0.164691,0.102878,0.138602, &
            -0.167214,-0.060581,-0.047205,0.040623,-0.016299,0.092164,0.090412,0.088489, &
            -0.153640,-0.017967,-0.039220,0.129130,-0.018379,0.300721,0.113088,-0.037772, &
            -0.051345,0.112183,0.073925,0.025585,0.110815,-0.013369,-0.015684,0.272336, &
            0.091489,0.044340,0.026432,0.179483,0.003865,0.185307,-0.121574,-0.063448, &
            0.337822,0.208119,0.247523,0.426874,0.179036,-0.229975,-0.237089,-0.122418, &
            0.916244,-0.629700,0.157782,0.034739,0.182116,-0.097438,-0.121023,0.601271, &
            0.011975,0.238083,-0.550212,0.184633,0.470387,0.250878,-0.578825,0.844880, &
            0.072381,-0.361037,0.155835,-0.273527,-0.154344,0.049767,0.491907,0.931844, &
            -0.333036,0.120776,-0.084347,0.216196,-0.097848,0.581168,0.182567,0.766890, &
            0.114552,0.343704,-0.187438,-0.510011,-0.265757,0.812017,0.283670,0.247843, &
            -0.098889,0.146067,-0.283960,-0.185917,-0.177205,0.780505,-0.348068,1.125272, &
            -0.389573,-1.045488,0.234940,-0.224517,-0.647675,0.236452,0.482068,-0.499923, &
            -0.551520,-0.415298,-0.488502,0.165354,-0.179848,-0.841351,0.252207,-0.075548, &
            -0.268769,-0.160900,-0.299725,0.076005,0.108559,0.013618,-0.078449,-0.332837, &
            -0.436919,-0.518196,-0.381685,-0.165445,-0.157607,0.222438,-0.163255,-0.963436, &
            -0.306665,-0.155092,0.194389,-0.188330,-0.216144,-0.605863,-0.284035,0.060251, &
            -0.072147,-0.015365,0.301157,0.056884,-0.395282,-0.259299,-0.130875,0.043921, &
            -0.120850,-0.129690,0.174465,0.028192,-0.199793,-0.233214,-0.090765,0.390700, &
            -0.160626,-0.141773,0.203348,0.198473,-0.265553,-0.408766,-0.056724,0.419225, &
            -0.265347,-0.159882,-0.060248,-0.087670,-0.322687,-0.592741,0.188331,0.372238, &
            -0.276341,-0.306898,0.177956,-0.058698,-0.151953,-0.589910,-0.035531,0.299225, &
            0.000762,-0.210330,0.179465,-0.030647,-0.067580,-0.611422,0.063241,0.185136, &
            -0.008244,-0.218736,0.235804,0.187795,-0.336054,-0.270071,-0.008676,-0.114446, &
            0.031400,-0.090339,0.243833,-0.491617,-0.304679,-0.118014,0.263054,0.210091, &
            -0.214568,-0.864267,0.221394,-0.261093,-0.210180,-0.325351,0.341017,0.202328, &
            -0.254502,-0.431822,-0.060396,-0.440377,-0.081989,-0.323468,0.024256,0.807093, &
            -0.349351,-0.748351,0.230058,-0.591807,-0.216839,-0.183121,-0.195321,0.711500, &
            -0.263920,-0.413290,0.040177,-0.247269,-0.147226,-0.090051,-0.094665,0.627886, &
            -0.329384,-0.431862,0.148357,-0.463994,0.161668,-0.159541,0.026759,0.044819, &
            -0.206289,-0.328594,-0.143494,-0.418938,-0.103550,-0.206991,0.050681,-0.326036, &
            -0.152445,0.005511,-0.112976,0.043149,-0.016900,-0.292241,-0.039022,-0.160402, &
            0.160710,-0.610201,0.047880,-0.407571,-0.067904,-0.209796,-0.064510,-0.766403, &
            0.093190,-0.852947,-0.120726,-0.412566,0.027813,0.136919,-0.069827,-0.537015, &
            0.154591,-0.078720,0.030166,0.146257,0.084085,0.286560,-0.035372,0.330776, &
            0.007498,0.183948,0.027454,0.256553,-0.053661,0.083012,0.097153,0.477546, &
            0.016440,0.183838,0.022819,0.219684,-0.019552,-0.055904,0.103609,0.372419, &
            0.080122,-0.163386,-0.069293,-0.034974,-0.059126,0.180556,-0.069404,0.222931, &
            -0.229633,0.020469,0.117278,0.037670,-0.046463,-0.059006,-0.076251,-0.172292, &
            -0.074388,-0.078423,-0.029826,-0.187859,0.020403,-0.053003,-0.042881,-0.331923, &
            -0.082165,0.098124,0.063533,0.151941,-0.065564,-0.008250,-0.008742,-0.028142, &
            -0.067564,0.087438,0.014410,0.139104,-0.012035,0.014551,0.042992,0.132539, &
            0.319502,-0.110607,-0.156520,-0.128444,0.087691,0.125168,-0.036777,0.488628, &
            0.309842,0.080409,-0.119781,-0.109812,-0.063741,-0.137811,-0.065070,-0.203435, &
            -0.111326,-0.268435,-0.320035,-0.263063,0.001058,0.229172,0.150779,0.071898, &
            -0.151165,0.023558,0.209433,-0.107892,0.035794,-0.201049,-0.149356,0.226555, &
            0.077637,0.087260,-0.232531,0.230607,-0.201127,0.305973,0.183117,-0.168054, &
            -0.311167,-0.194534,-0.190752,0.050969,-0.295504,0.478694,0.036650,-0.457274, &
            0.128027,-0.038972,0.104072,-0.022552,0.279089,0.145433,-0.045492,-0.219497, &
            -0.225934,0.069967,-0.179750,-0.132150,-0.189715,-0.052667,0.136023,-0.427869, &
            -0.056470,-0.205387,-0.072385,-0.254896,-0.109417,-0.398520,-0.034042,-0.307051, &
            0.179942,0.139467,0.112127,-0.006963,0.258575,-0.207202,-0.029338,-0.234898 &
            /),(/8,126/))
real, dimension(2,8) :: hidden1 = &
  Reshape((/-0.655158,2.572784, &
            3.209143,-1.983959, &
            0.753949,4.262635, &
            0.343621,-1.488668, &
            0.215291,-2.189988, &
            0.197044,0.495566, &
            0.330055,3.955593, &
            -0.978652,-0.716693 &
            /),(/2,8/))
real, dimension(1,2) :: hidden2 = &
  Reshape((/0.667952,2.736953/),(/1,2/))
real, dimension(8) :: bias1 = &
(/1.580678,-2.334887,1.514531,-1.712316,-1.615428,1.642275,1.593012,-1.026187/)
real, dimension(2) :: bias2 = &
(/-0.512042,0.339122/)
real, dimension(1) :: bias3 = &
(/-0.502991/)
contains
subroutine fnet_EMM_initall()
end subroutine fnet_EMM_initall
subroutine fnet_EMM_engine(inarray, outarray, init)
  intrinsic MatMul, Size
  real, dimension(:), intent(in) :: inarray
  real, dimension(:), intent(inout) :: outarray
  real, dimension(126) :: inarray2
  real (kind=8), dimension(8) :: layer1
  real (kind=8), dimension(2) :: layer2
  real (kind=8), dimension(1) :: layer3
  integer , intent(inout) :: init
  integer :: i, j
  !do i = 1, 126
  !  inarray2(i) = inarray(127-i)
  !end do
  layer1 = MatMul(input,inarray)
  layer1 = layer1 + bias1
  do i = 1, Size(layer1,1)
    layer1(i) = 1.0 / (1.0 + DEXP(-1.0 * layer1(i)))
  end do
  layer2 = MatMul(hidden1,layer1)
  layer2 = layer2 + bias2
  do i = 1, Size(layer2,1)
    layer2(i) = 1.0 / (1.0 + DEXP(-1.0 * layer2(i)))
  end do
  layer3 = MatMul(hidden2,layer2)
  layer3 = layer3 + bias3
  outarray(1) = layer3(1)
end subroutine fnet_EMM_engine
end module fnet_EMM