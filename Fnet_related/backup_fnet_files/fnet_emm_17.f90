module fnet_EMM

! a = 0.00014203
! b = 0.075691

intrinsic Reshape
real, dimension(8,126) :: input = &
  Reshape((/0.028672,0.076588,0.205881,0.061835,-0.077914,-0.135279,0.067530,-0.068902, &
            -0.091380,0.025055,0.155085,-0.179605,-0.183466,-0.203404,-0.099092,-0.070488, &
            -0.045328,0.022896,0.192985,-0.226197,-0.194402,-0.119437,-0.122756,-0.008317, &
            -0.049134,0.038146,0.124021,-0.164806,-0.010275,-0.105369,-0.143160,0.052980, &
            0.048091,0.018330,0.003403,-0.152831,0.004161,-0.078647,0.010087,-0.127478, &
            -0.192369,0.004116,0.092153,-0.044032,0.097375,-0.020829,0.036200,-0.021895, &
            -0.203536,-0.078570,0.001082,-0.052017,-0.019169,0.053708,0.037009,0.043835, &
            -0.093073,-0.126177,-0.078487,0.040490,-0.121357,0.177094,0.102744,0.083514, &
            -0.140740,-0.069613,0.517234,-1.056117,0.071267,0.206324,-0.003974,0.034488, &
            0.016636,-0.102194,0.338169,-0.412971,0.176895,0.026870,0.114281,0.318860, &
            0.140875,0.149865,-0.009727,0.279267,-0.059012,-0.050511,-0.084284,-0.149712, &
            0.187636,0.163097,-0.060408,0.491020,0.243344,-0.474795,-0.043158,-0.043863, &
            0.315413,0.031458,-0.097857,0.244171,-0.032984,-0.336750,0.085264,-0.069350, &
            -0.077517,-0.116494,-0.090477,-0.454064,-0.073414,0.271472,0.017239,-0.016916, &
            0.043172,-0.156218,-0.184888,-0.278298,-0.185433,-0.200025,-0.146647,0.049344, &
            0.114752,-0.038056,0.070267,0.752469,-0.331525,0.202224,0.609437,-0.010853, &
            0.494350,0.238831,0.308849,0.298307,0.355572,-0.403801,0.897875,-0.314873, &
            -0.122791,0.279543,0.285838,0.278937,0.578650,-0.020434,0.332570,0.013346, &
            -0.001602,0.005523,-0.138472,-0.304940,0.017910,0.111401,0.078670,-0.151918, &
            -0.138372,0.175325,0.167320,-0.296932,-0.047584,-0.061541,-0.059951,-0.043934, &
            0.051775,0.191586,0.094500,-0.191103,-0.138560,0.171932,-0.209485,0.067510, &
            0.021794,0.010088,0.262837,-0.119667,-0.374793,-0.138067,-0.224113,0.232999, &
            -0.219634,0.099386,0.044939,-0.429495,0.035322,-0.291220,-0.040016,0.046637, &
            -0.284938,0.122934,0.069775,-0.428109,-0.020518,-0.278453,-0.137303,0.073448, &
            -0.193618,0.199782,0.232640,0.062613,-0.015196,-0.099959,0.168997,0.169875, &
            -0.044433,0.127123,0.035634,-0.199339,-0.285824,0.040278,0.304709,0.383260, &
            -0.313819,0.152868,-0.793162,-0.955148,-0.286115,-0.135766,-0.245940,0.112184, &
            -0.769826,0.209061,-0.272496,-0.763258,-0.148108,-0.049818,-0.161265,0.248130, &
            -0.593195,0.038573,-0.123686,-0.969105,0.040282,0.175433,-0.408686,0.492904, &
            0.047412,0.087355,-0.001554,-0.337262,-0.298967,-0.118965,-0.030192,-0.154908, &
            -0.213586,0.055214,0.329056,0.134348,0.054004,-0.262595,-0.167413,0.030470, &
            -0.633107,-0.118286,0.103381,0.000208,-0.072186,-0.142205,0.325866,-0.043093, &
            0.023450,0.220747,0.121446,0.416103,-0.081980,0.172739,-0.275483,-0.113783, &
            0.188203,0.015578,-0.341912,0.938671,-0.011988,-0.322567,-0.049832,0.001957, &
            -0.467410,0.071449,-0.703426,0.492817,0.722126,-0.028265,0.000283,0.055924, &
            -0.389047,0.054211,-0.112666,0.757643,0.195156,0.672047,-0.458748,0.570025, &
            2.759586,-1.607069,2.491073,2.424581,1.807923,3.598697,-2.122367,-2.929515, &
            3.033197,-1.792396,2.517473,2.690899,1.769999,3.597467,-2.217865,-2.862214, &
            2.928900,-1.608427,2.359420,2.624423,1.577726,3.409340,-2.074880,-2.870847, &
            2.577843,-1.313070,2.430806,2.491799,1.497775,3.354229,-2.185377,-2.731596, &
            2.490398,-1.562823,2.346432,2.313677,1.872308,3.144512,-2.087366,-2.988856, &
            2.660745,-1.704582,2.586565,2.424316,1.741311,3.588146,-1.895550,-2.727238, &
            2.892730,-2.004413,2.783182,2.676649,1.968002,3.609304,-2.155374,-3.265258, &
            3.173267,-2.055136,3.084292,3.053272,2.328622,3.822830,-2.461914,-3.416991, &
            4.529679,-4.414609,5.047119,5.222642,4.208661,5.607603,-3.582779,-4.541600, &
            4.210637,-3.922548,3.970346,4.168844,3.709379,5.286972,-2.771459,-4.304392, &
            3.049013,-2.512757,1.507151,2.120963,2.067760,3.823593,-1.955871,-3.154337, &
            1.837637,-0.856699,-0.040056,0.718459,0.565639,2.520373,-0.920532,-2.358601, &
            1.073856,-0.301602,-0.176967,0.246274,0.044518,1.806521,-0.168267,-1.995088, &
            0.550619,-0.132764,0.209494,-0.053748,-0.367693,0.736729,0.389493,-1.233774, &
            0.156466,0.157155,0.298430,-0.509289,-0.420708,0.337525,0.168218,-0.741585, &
            0.140657,-0.030031,0.281540,-0.677180,-0.316022,0.047429,-0.113346,-0.472766, &
            -0.100572,0.129583,0.172620,-0.413861,0.234080,0.013672,-0.375838,-0.732592, &
            -0.113508,-0.019787,-0.279578,-0.334252,-0.067496,0.445536,-0.240305,-0.841105, &
            0.351798,-0.394658,0.272312,0.566774,0.085738,0.709363,-0.151809,-0.455938, &
            0.370862,-0.297087,0.465003,0.517999,0.138155,0.655766,0.065044,-0.442897, &
            0.259317,-0.493376,0.241803,0.736873,0.451593,0.735631,0.032348,-0.508617, &
            0.504298,-0.398451,0.137560,0.694193,0.330483,0.442861,0.100115,-0.149319, &
            0.565898,-0.391551,0.113253,0.552502,0.502238,0.639565,-0.051260,-0.375385, &
            0.306725,-0.758848,0.475073,0.851120,0.566330,0.411850,0.224502,-0.487679, &
            0.426151,-0.489270,0.524644,0.714484,0.629606,0.486691,0.192502,-0.414337, &
            0.560598,-0.616115,0.421706,0.893711,0.344516,0.637141,-0.116428,-0.271186, &
            0.434656,-0.797862,0.401314,1.001332,0.671198,0.564148,0.195909,-0.221045, &
            0.220413,-0.962512,0.447122,0.969705,0.512676,0.812617,-0.034761,-0.425766, &
            0.103647,-0.508344,0.052109,0.375909,0.144880,0.951049,0.601405,-0.309952, &
            0.403674,-0.354866,0.158309,0.042406,0.208815,1.124672,0.531990,-0.551454, &
            0.112624,-0.135603,-0.223843,-0.331539,-0.125270,0.683479,0.763066,-0.618902, &
            0.090159,0.194889,-0.074417,-0.061940,-0.222597,0.535453,1.094049,-0.275227, &
            0.075333,-0.246997,0.048343,-0.190382,-0.077333,0.116486,0.988606,0.159088, &
            0.059455,-0.279197,0.404624,-0.128299,0.122310,0.025576,0.854082,-0.047904, &
            0.192977,0.264426,0.140176,-0.365547,0.065119,0.225087,0.950760,-0.330146, &
            0.183108,-0.163457,0.616737,-0.390483,0.410776,0.352614,0.436887,-0.564216, &
            0.156081,0.400028,-0.354345,0.002140,-0.125679,-0.644669,0.249861,-0.505063, &
            0.119837,0.239259,-0.243045,0.342102,0.079030,-0.605104,-0.113740,-0.311457, &
            -0.046960,0.252427,0.027874,0.360068,0.146337,-0.297017,-0.013465,-0.236887, &
            0.020030,-0.007776,0.066312,-0.012191,-0.139239,0.223661,-0.051442,0.080886, &
            -0.319577,-0.009719,0.058018,-0.063299,0.031967,0.283255,-0.023453,0.133935, &
            -0.306566,0.115139,0.141249,-0.146912,0.141982,0.339013,-0.083733,-0.051627, &
            -0.188281,-0.048809,0.076241,-0.298639,-0.143475,0.164909,-0.054467,-0.189189, &
            -0.008256,-0.050279,-0.281617,-0.282899,0.372742,0.244573,0.263159,-0.293555, &
            0.057107,0.667929,-0.311125,-0.714601,0.211399,-0.092772,0.070078,-0.137889, &
            0.676870,-0.246075,0.090880,0.014615,0.419433,-0.249826,-0.793377,-0.899976, &
            -0.392316,0.263495,-0.270900,-0.187131,-0.348886,-0.217650,-0.189296,0.296604, &
            -0.006529,-0.069438,0.055623,-0.445939,0.104101,0.295874,-0.689152,-0.077837, &
            0.508687,0.096287,-0.644698,-0.459617,-0.453642,-0.700485,-0.876348,-0.018657, &
            0.326435,-0.081475,-0.130177,-0.739047,0.285391,0.112609,-1.167357,-0.225520, &
            -0.635241,0.303319,-0.596627,-0.379273,-0.569878,-0.562062,-0.062757,0.583088, &
            -0.233772,-0.558515,0.392498,0.331674,-0.209047,-0.097556,-0.066328,0.296103, &
            -0.074051,-0.189416,0.159869,-0.782886,0.285124,-0.227803,-0.265592,0.125949, &
            0.082110,-0.177984,-0.075562,0.339383,0.257264,-0.417295,-0.056020,-0.023735, &
            -0.091632,-0.257431,-0.251844,-0.118898,0.029500,-0.243695,-0.106483,0.243906, &
            -0.210927,-0.067666,-0.150836,-0.252427,-0.124070,-0.137151,-0.139179,0.258042, &
            -0.131945,-0.205765,-0.480761,-0.076919,-0.007725,-0.202462,-0.222846,0.151771, &
            -0.013702,-0.264490,-0.194872,0.046768,-0.034659,-0.413276,-0.230615,0.452638, &
            -0.141301,-0.063047,-0.243019,0.000130,-0.098046,-0.297576,-0.113604,0.249085, &
            -0.209353,-0.131807,-0.222386,0.111837,0.067556,-0.237318,0.031826,0.185862, &
            -0.159979,-0.257417,-0.252437,-0.233415,-0.076489,-0.191316,0.086784,0.203247, &
            -0.334915,0.076517,0.017030,-0.044197,0.066442,-0.156438,0.140801,0.193003, &
            -0.232450,0.321394,-0.389546,-0.423984,-0.337320,-0.353028,0.176289,0.342193, &
            -0.301473,0.293537,-0.023430,-0.578758,-0.134038,-0.849852,0.008412,0.403487, &
            -0.095704,-0.078219,0.129070,-0.113811,0.005781,-0.738285,-0.354385,0.326732, &
            -0.205393,0.165651,0.233250,-0.481688,0.168546,-0.501043,-0.300977,0.315596, &
            0.004007,-0.285409,0.105066,-0.388502,-0.049259,-0.273053,-0.058327,0.497176, &
            0.000749,0.029822,0.141280,-0.366341,0.239055,-0.123181,0.109293,0.295104, &
            -0.211322,-0.169940,0.007453,-0.120728,-0.132731,-0.231133,0.083235,0.149729, &
            0.184130,-0.163321,0.288107,0.032056,-0.007039,0.059444,0.253896,0.249850, &
            -0.203983,0.062543,0.062007,-0.210485,0.026223,-0.154537,0.299391,-0.037138, &
            0.159986,0.031499,0.114210,-0.121695,0.333799,-0.342051,0.356623,-0.110901, &
            -0.095570,0.070223,0.123151,0.085268,0.146320,0.177156,-0.083430,0.127830, &
            0.009001,0.047827,-0.020747,0.231848,0.003359,0.041009,-0.116015,0.012774, &
            -0.130217,-0.109958,-0.191058,0.117603,0.030936,0.178754,0.080180,0.099544, &
            0.080070,0.019249,-0.183742,0.312536,0.160640,-0.042411,0.084996,0.078521, &
            -0.123219,-0.045682,-0.101318,0.007314,-0.028854,-0.156411,0.016366,-0.187731, &
            0.104282,0.045019,-0.160341,0.350003,-0.049156,0.041857,-0.014029,-0.054115, &
            0.013719,0.038196,-0.057234,0.286589,-0.004105,0.063623,0.025790,-0.047525, &
            -0.074972,-0.013736,0.107053,0.040609,0.050764,0.012915,0.019295,-0.012509, &
            -0.107381,-0.072249,0.019413,-0.198682,-0.014531,-0.048999,0.057518,-0.101878, &
            0.239802,0.115255,0.069830,0.155101,0.376881,-0.297493,-0.129040,0.216016, &
            0.165436,0.005210,-0.126266,0.657985,0.143888,0.215665,-0.151034,0.462772, &
            0.541022,0.178992,0.410486,-0.442672,-0.287602,0.325797,-0.124149,0.254694, &
            0.388766,-0.155660,-0.028795,-0.302827,-0.313794,-0.224575,0.207230,0.007615, &
            0.168567,0.016141,0.310674,0.089073,-0.182836,-0.136802,0.088417,-0.063139, &
            -0.099793,0.097592,0.013109,-0.028854,0.039555,-0.247632,0.045575,-0.348443, &
            -0.084558,-0.180782,-0.389341,0.359803,0.000751,0.052069,-0.005262,0.211075, &
            -0.042680,-0.046754,0.226701,-0.115303,-0.199747,0.165957,0.093052,0.019574, &
            0.024820,0.097984,0.108364,-0.327388,0.208671,0.094017,0.273961,-0.309934 &
            /),(/8,126/))
real, dimension(2,8) :: hidden1 = &
  Reshape((/-1.570989,-1.673168, &
            -0.951566,3.724988, &
            0.481979,-1.227050, &
            -0.505205,-0.984415, &
            0.383507,-1.320862, &
            -2.019341,-1.565081, &
            1.651541,2.832289, &
            3.158641,2.625571 &
            /),(/2,8/))
real, dimension(1,2) :: hidden2 = &
  Reshape((/-0.604987,3.022858/),(/1,2/))
real, dimension(8) :: bias1 = &
(/-1.525639,1.552906,-1.668386,-1.538146,-1.628225,-1.742612,1.262843,1.664353/)
real, dimension(2) :: bias2 = &
(/-0.099296,0.711696/)
real, dimension(1) :: bias3 = &
(/0.1145/)
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
  !integer :: i, j
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