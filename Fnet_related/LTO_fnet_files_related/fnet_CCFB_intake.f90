module fnet_CCFB_intake

! a = 0.00076145
! b = 0.026005

intrinsic Reshape
real, dimension(8,126) :: input = &
  Reshape((/0.108986,-0.264956,-0.084885,-0.243162,0.085783,-0.223147,0.145920,-0.053378, &
            -0.066210,-0.065360,-0.034284,0.001085,-0.040155,-0.041673,0.140811,0.020481, &
            -0.019683,-0.073964,-0.018104,-0.025595,0.064181,-0.077344,0.011617,-0.029422, &
            -0.039656,-0.186835,0.037900,0.036552,-0.035744,0.010665,-0.005478,0.006804, &
            -0.070607,0.167578,0.007410,-0.011437,-0.008772,-0.056007,0.040521,-0.017940, &
            -0.060830,0.057885,0.003324,0.039235,0.007601,-0.054506,-0.032202,-0.037107, &
            -0.079670,-0.027143,0.048150,0.031224,-0.001082,-0.008878,0.048688,-0.018932, &
            -0.037905,-0.132625,0.036774,0.050873,0.128949,-0.066265,-0.125647,-0.096636, &
            -0.348336,-0.387632,0.109795,-0.029797,0.170892,-0.201537,0.555505,-0.219339, &
            -0.487575,-0.022664,-0.076418,-0.354449,-0.156148,-0.275612,1.062187,0.073822, &
            -1.147339,1.438222,0.085160,0.138250,-0.249920,-0.126541,1.164772,0.128028, &
            -0.859844,0.238098,0.180672,0.251245,-0.328995,0.007969,1.157961,0.108910, &
            -0.311027,-0.439882,0.307090,0.084939,-0.186963,0.258478,0.337406,0.119897, &
            -0.181089,-0.428325,0.398760,0.050418,-0.050816,0.297350,0.099571,0.097148, &
            -0.046610,0.448719,0.372746,-0.028170,-0.431981,0.415381,0.270933,0.248485, &
            -0.284262,1.131430,0.206005,-0.032727,0.261485,0.536277,0.610664,0.200766, &
            -0.215339,0.990892,0.456450,-0.014083,-0.183909,0.976939,0.457477,0.422990, &
            -0.316331,-0.480399,-0.004087,0.001818,0.442774,0.664987,0.992547,0.324525, &
            -0.084647,0.316769,0.683594,-0.474652,0.467194,0.449705,-0.924268,-0.025583, &
            0.066811,0.061331,0.319483,-0.935712,0.173741,0.480160,-0.434026,0.306050, &
            0.075818,-0.225095,0.566924,-0.363344,0.027206,0.401812,-0.341819,0.191906, &
            0.151524,-0.210925,0.386351,0.131608,0.007996,0.269550,-0.349870,-0.010264, &
            0.086745,-0.143077,0.321378,0.086508,-0.148241,0.425302,-0.195190,0.098419, &
            0.195809,-0.469651,0.206161,-0.159162,0.187985,0.038119,-0.192761,-0.062514, &
            0.331849,-0.282322,-0.012576,-0.143008,0.004798,0.039605,-0.209914,-0.004970, &
            0.062692,-0.494099,0.130519,-0.302282,0.268975,0.190054,-0.198230,0.067824, &
            0.519113,-1.059294,-0.236152,-0.344845,0.172750,-0.129652,-0.804902,0.393209, &
            0.230748,-0.403994,-0.261076,-0.381499,0.098761,-0.202398,-0.555346,0.682564, &
            -0.323683,0.604911,-0.503537,0.016515,0.140892,-0.185513,0.236970,0.619812, &
            -0.226174,0.711675,-0.238997,-0.227203,0.064238,-0.245719,0.958783,0.385895, &
            -0.212853,-0.241131,-0.408856,-0.099045,0.318881,-0.118796,1.152245,0.452029, &
            -0.444780,-1.297131,-0.127440,-0.035571,0.101082,0.005342,0.972612,0.443867, &
            -0.212498,-1.231416,-0.223609,0.179212,-0.071543,0.130925,0.323008,0.238517, &
            -0.037604,-0.910727,-0.468512,0.185792,0.284358,-0.106844,-0.506885,-0.041226, &
            0.367898,-0.441238,-1.069981,-0.056406,0.121359,-0.621351,-0.711361,-0.042733, &
            -0.010737,0.935057,-1.122422,0.538545,1.175523,-0.904772,-1.216889,-0.580256, &
            -0.106549,-1.770742,0.214113,0.639897,0.236587,-1.138228,-1.049457,-0.526938, &
            -0.667229,-1.729018,-0.144889,0.173241,0.155122,-1.004077,-0.799335,-0.291022, &
            -0.524084,-1.335006,-0.499653,0.282087,-0.195762,-0.875947,0.113607,-0.257977, &
            -0.264527,-0.613043,-0.207753,0.048173,-0.126615,-0.993541,0.504145,-0.395545, &
            -0.169979,-0.542588,-0.301773,0.060439,-0.201106,-1.236771,0.280987,-0.441583, &
            -0.091592,-0.211790,-0.119315,-0.064057,-0.232133,-1.150917,0.373005,-0.499684, &
            -0.062415,-0.189245,-0.184848,0.002566,-0.058979,-1.350076,0.210967,-0.657002, &
            -0.044958,-0.162307,-0.407710,-0.000722,0.156169,-1.695137,0.068798,-1.103676, &
            -0.476178,0.378547,-0.698266,-0.180666,-0.809246,-1.179491,1.222026,-5.108259, &
            -0.876092,1.486714,0.517523,-0.265752,-0.691681,-1.148112,2.565374,-7.794179, &
            -1.194897,2.159735,-1.238580,0.271520,-0.279243,-0.480013,2.325563,-8.185329, &
            -0.602299,2.046503,0.267877,-0.061567,-0.543278,0.374318,1.003448,-7.058878, &
            -0.466809,3.742981,-0.069176,0.133874,1.066911,0.842461,-0.086977,-5.857686, &
            -0.339478,3.742253,-0.277412,0.233609,2.677996,0.946133,-0.005949,-4.080850, &
            -0.300765,3.409586,0.681191,-0.056749,2.250250,0.777153,-0.077022,-2.745555, &
            0.023939,2.607575,0.298475,-0.398821,2.167090,-0.619444,-0.181461,-1.343094, &
            0.020549,2.235127,-0.189262,-0.112371,1.106126,-1.352465,-0.180480,-1.360038, &
            0.708819,2.639529,-0.616782,0.115373,1.530479,-0.151873,-0.690358,-2.568384, &
            -1.425314,2.770951,-0.666065,-0.787658,4.210541,-2.110185,0.367504,-0.882358, &
            -2.137573,1.741614,-1.198744,-1.763571,4.002128,-1.890438,-0.022458,-1.087979, &
            -1.357933,2.030581,-0.501400,-1.077516,3.666342,-1.780000,0.447049,-1.187777, &
            -0.890394,1.832998,0.393556,-0.897992,3.789005,-1.637257,0.750969,-0.990291, &
            -0.275126,1.496125,0.420607,-0.460773,3.565022,-1.580171,0.779504,-1.001285, &
            -0.339706,1.570287,0.508683,-0.166243,3.472968,-1.747625,0.469222,-1.341218, &
            0.005219,1.306277,0.925917,-0.103145,3.463268,-1.682014,0.153747,-1.342691, &
            -0.279292,0.809499,0.820787,0.204051,3.241667,-1.760312,-0.004763,-1.656176, &
            0.156745,0.335397,1.122857,0.420565,2.746448,-1.565589,-0.427890,-2.186706, &
            0.665370,-0.530071,-0.479826,-0.629951,1.107579,-0.421530,0.367795,-3.236591, &
            0.790867,-0.702419,-3.824211,-1.543033,0.531944,0.018785,-0.352102,-2.711536, &
            0.741621,-1.474382,-1.157170,-0.198560,0.767454,-0.107055,-0.428781,-1.735016, &
            0.750441,-2.338555,0.825088,0.106922,0.713815,-0.262944,-0.443500,-1.465906, &
            0.353147,-2.142306,0.263649,0.151502,0.538064,-0.261210,-0.003167,-1.263514, &
            0.167430,-0.005281,-0.005445,0.326064,0.758736,-0.401554,-0.267422,-0.752953, &
            0.152047,1.315314,-0.300513,0.394057,0.718843,-0.572215,-0.575077,-0.934476, &
            -0.338300,1.892694,-0.444972,0.205312,1.172187,-1.084179,-0.021746,-1.004169, &
            -0.442021,1.204571,-1.544650,0.437383,1.040417,-1.238106,-0.136515,-1.954571, &
            0.128120,-0.493276,-0.166708,-0.055002,-0.390788,-0.255059,-0.031754,0.033848, &
            0.005347,-0.047608,-0.107931,0.072645,-0.077427,0.010795,0.092735,0.015586, &
            0.014247,-0.104862,0.128815,-0.072199,0.062814,-0.124270,-0.101964,-0.064173, &
            0.047789,-0.202223,-0.084411,-0.043072,-0.003885,-0.191792,-0.108234,-0.053710, &
            0.003032,-0.061800,-0.111903,-0.056220,-0.113662,-0.049385,-0.071388,0.096873, &
            0.029158,-0.064056,-0.075741,0.058021,-0.139105,-0.060359,-0.095239,0.032893, &
            0.073201,-0.299418,0.035178,-0.050796,-0.063592,-0.150888,-0.081372,-0.033944, &
            0.096398,-0.558414,-0.184740,0.032301,-0.434223,-0.078068,-0.174459,0.116040, &
            -0.060473,-1.808545,0.059614,-0.139835,-1.368607,-0.308455,-1.422529,0.710039, &
            0.453494,-1.843265,0.122428,-0.319224,-1.599786,-0.336304,-1.367006,0.635302, &
            0.528099,-0.398905,0.320745,0.090399,-1.012183,0.358508,0.309176,0.524609, &
            0.455721,-0.752912,0.501836,0.249769,-1.304006,0.575780,0.471889,0.337542, &
            0.530488,-0.763484,0.233704,0.185436,-0.853663,0.926362,0.893966,0.406310, &
            -0.034209,-0.682928,0.002647,0.225813,-0.819278,0.148609,0.944762,-0.115707, &
            -0.470525,-0.123825,0.296423,0.222666,-0.359090,0.034289,0.623944,-0.178425, &
            -0.716592,-0.075781,0.694250,0.048430,-0.158118,0.042725,-0.077099,-0.310896, &
            -0.174537,-0.607161,-0.014762,0.008680,-0.319212,-0.454338,-0.163196,-0.226815, &
            -0.378934,0.262436,0.138493,0.105762,0.083155,-0.387242,-0.299665,-0.347683, &
            -0.030702,0.456063,0.130890,-0.248095,0.424026,-0.262286,0.149190,-0.337306, &
            0.187993,0.213895,-0.326252,-0.419460,0.254293,-0.288929,-0.224730,-0.173040, &
            0.219278,0.126231,-0.286792,-0.522903,0.344288,-0.265530,-0.099945,-0.179030, &
            0.125946,0.034089,-0.036775,-0.406290,0.158112,-0.384566,-0.216424,-0.160216, &
            0.097886,-0.150017,-0.033570,-0.312158,0.337751,-0.215660,0.018266,-0.093603, &
            0.312339,-0.245852,-0.111616,-0.325961,0.342572,-0.168691,0.016453,-0.065703, &
            0.200458,-0.095575,-0.076844,-0.158570,0.079294,-0.018474,0.235488,0.017751, &
            0.208561,-0.188978,-0.265598,-0.315866,0.356395,0.131253,0.245169,0.059497, &
            0.235965,-0.627935,-0.464558,-0.422693,-0.027148,0.719692,0.353107,0.833064, &
            0.311850,-0.712585,-0.477799,-0.104062,-0.556826,0.645351,-0.061679,1.019007, &
            0.403920,-1.202917,0.154104,-0.475047,-0.581456,0.447004,-1.720606,0.786420, &
            0.314044,-0.008544,-0.586140,-0.022083,-0.431614,0.637019,-0.082665,0.928142, &
            -0.047672,0.638101,-0.946688,0.264874,-0.374927,0.810304,0.796681,0.677555, &
            -0.197234,1.881926,-1.208810,0.454130,-0.746884,0.530658,0.692358,0.485410, &
            -0.084152,1.344936,-0.576908,0.083233,-0.342816,0.013262,0.233351,0.504714, &
            0.043981,0.146559,-0.134519,0.001932,-0.489898,-0.112627,-0.401335,0.089727, &
            -0.058122,0.355068,-0.199633,0.033193,-0.263759,-0.178269,-0.427232,0.104060, &
            -0.129317,-0.178477,-0.204223,0.388356,-0.252347,0.138152,-0.607042,-0.013461, &
            0.196868,-0.260700,0.045186,0.041528,-0.060174,0.099101,-0.086995,-0.023890, &
            -0.017098,0.215977,-0.160650,-0.028159,0.145903,-0.113045,-0.062894,-0.040351, &
            -0.106861,0.419996,-0.037418,-0.058689,0.075777,0.006797,0.052143,0.023647, &
            -0.052764,0.165537,-0.022598,0.003933,0.122523,0.051137,-0.069291,0.009192, &
            -0.066866,0.073150,0.058502,-0.022076,-0.111544,0.021329,0.176266,0.040406, &
            0.087010,-0.176069,-0.021575,-0.020302,0.026612,0.007554,-0.040209,-0.005626, &
            -0.026572,0.078933,-0.040182,-0.027610,0.064816,-0.079921,-0.001830,-0.027549, &
            0.035334,0.110807,0.051783,-0.060649,0.025583,0.056060,-0.107650,0.014304, &
            0.096087,0.005840,-0.139078,-0.010381,0.148545,0.011042,-0.174687,0.004869, &
            -0.107669,0.323142,-0.105914,0.102633,-0.168545,-0.162828,-0.152942,-0.010937, &
            -0.082614,0.632224,0.152359,-0.058110,-0.377373,0.008087,0.037782,0.036057, &
            -0.036921,0.549490,0.016409,0.137350,-0.316094,0.076864,-0.213297,0.042022, &
            -0.047842,0.434294,-0.196250,0.104144,0.102073,-0.141681,-0.285919,-0.105407, &
            0.092829,0.427510,-0.122557,-0.124266,0.302041,-0.124500,0.049867,-0.110326, &
            -0.051673,-0.145368,-0.148197,0.139890,-0.138136,0.002574,-0.157708,0.049314, &
            -0.022758,0.188619,0.279179,0.136117,-0.192403,0.243559,-0.491313,0.060778, &
            0.108554,0.236185,0.113092,-0.073216,-0.051935,0.041181,-0.028315,-0.033953, &
            -0.123292,0.382873,-0.237957,0.039617,-0.088092,-0.217662,0.081001,-0.063475 &
            /),(/8,126/))
real, dimension(2,8) :: hidden1 = &
  Reshape((/-1.019978,0.764188, &
            -0.252811,0.054919, &
            -1.908050,-2.897140, &
            -1.244285,-2.054702, &
            -0.595428,-0.241784, &
            1.681377,-0.589461, &
            0.260029,-1.391773, &
            -4.860620,-4.983172 &
            /),(/2,8/))
real, dimension(1,2) :: hidden2 = &
  Reshape((/-2.571953,-1.174866/),(/1,2/))
real, dimension(8) :: bias1 = &
(/1.529955,-0.210812,1.231699,0.986048,-0.408466,-0.334449,-0.089178,0.940794/)
real, dimension(2) :: bias2 = &
(/0.66212,0.13526/)
real, dimension(1) :: bias3 = &
(/1.646505/)
contains
subroutine fnet_CCFB_intake_initall()
end subroutine fnet_CCFB_intake_initall
subroutine fnet_CCFB_intake_engine(inarray, outarray, init)
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
end subroutine fnet_CCFB_intake_engine
end module fnet_CCFB_intake