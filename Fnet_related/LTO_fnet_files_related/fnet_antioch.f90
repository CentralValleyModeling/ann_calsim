module fnet_antioch

! a = 8.5267e-005
! b = 0.087541

intrinsic Reshape
real, dimension(8,126) :: input = &
  Reshape((/-0.053383,0.066335,-0.194197,0.002103,0.152474,-0.612107,-0.085045,-0.009299, &
            -0.008096,-0.096462,-0.010643,-0.166704,0.033862,-0.152713,0.001561,-0.037574, &
            0.020594,-0.101241,-0.015239,-0.065363,0.076762,-0.136632,-0.148697,-0.004499, &
            -0.015886,-0.106071,0.042961,-0.125035,-0.031403,0.040623,0.078571,-0.004178, &
            -0.067762,-0.041608,-0.013958,0.031893,0.054766,0.125626,-0.031589,0.024381, &
            0.109106,-0.067138,-0.028552,0.004221,0.034030,-0.067233,-0.117364,0.031296, &
            0.060850,-0.143330,-0.034237,0.038852,0.037658,0.031883,-0.082316,0.077189, &
            0.044555,-0.133652,0.013799,-0.068450,0.004628,0.064139,-0.087850,0.039387, &
            0.306691,0.774196,-0.275488,-0.108158,0.137256,-0.224587,-0.421875,0.948815, &
            0.218402,0.013667,-0.219930,-0.211071,0.224768,-0.452761,-0.326835,0.361957, &
            0.204459,0.783658,-0.332840,-0.116415,0.521621,-0.438998,-0.566097,0.103043, &
            -0.349038,2.569102,-0.069886,0.167051,0.434024,0.248161,-0.176848,-0.460252, &
            -0.069002,-0.170924,0.041409,-0.023647,0.151359,0.255088,-0.122055,-0.060909, &
            0.330263,-0.995088,0.134867,-0.277525,-0.063743,0.073049,-0.223195,-0.100269, &
            0.422112,-0.308338,0.079525,-0.257600,0.034835,-0.219777,-0.422022,-0.030275, &
            0.450832,0.786251,-0.088830,-0.287710,0.231177,-0.220270,-0.660857,0.549240, &
            0.625458,1.088188,-0.222643,-0.517387,0.714674,0.508677,-0.868283,0.653449, &
            0.174337,1.565403,0.017880,-0.075632,0.485658,1.084487,-0.512175,0.328509, &
            -0.213119,-1.446249,-0.022757,0.065346,0.240229,-0.371220,-0.241076,-0.583029, &
            0.070024,-1.078845,0.270554,0.037867,0.149214,-0.118964,-0.071679,-0.437713, &
            -0.028051,-1.096091,0.056429,-0.097360,0.265530,-0.212498,-0.034142,-0.141638, &
            -0.115027,-0.786906,0.200451,0.015579,-0.030755,-0.098249,0.143751,0.064123, &
            -0.076911,-0.623795,0.256242,0.032446,0.043043,-0.077165,-0.174045,0.113980, &
            -0.146452,-0.865389,0.256942,0.132676,-0.018489,0.138135,0.042710,0.158146, &
            -0.208636,-0.660829,0.190632,0.267076,-0.111508,-0.177695,0.287886,0.043123, &
            0.138884,-0.997466,0.262091,0.062278,-0.068467,-0.201147,0.124832,0.156791, &
            -0.704068,-1.724536,0.226011,0.997075,-0.041374,-0.815477,0.616420,0.520692, &
            -0.515580,0.390092,0.338809,0.138419,0.021116,-0.097046,0.934294,0.442263, &
            -0.680616,-0.390123,0.063657,-0.321263,0.150832,-0.171926,1.009606,0.393677, &
            -0.582414,0.222935,0.424038,-0.028473,-0.165355,0.090831,0.439886,0.791236, &
            0.274507,0.699723,0.035899,-0.180983,0.314865,0.284589,0.232387,-0.006587, &
            0.518149,-1.514528,-0.232674,0.076934,0.288805,-0.209540,-0.268401,-0.165938, &
            0.219797,1.342269,0.175533,-0.435503,0.088762,0.300338,0.059416,-0.087267, &
            -0.190489,1.623341,0.110198,0.140136,0.044522,0.261585,0.123863,-0.112457, &
            0.142538,2.368514,0.060757,-0.016769,-0.233441,0.326462,0.162825,0.599191, &
            -0.792490,-1.123532,-0.069403,0.583097,-0.337585,0.283215,0.762571,0.547264, &
            -0.671593,-1.585857,-1.195010,2.619989,-1.317202,1.407453,2.919185,0.922375, &
            -0.739262,-1.619346,-2.405117,2.672752,-1.569932,1.574739,2.585448,0.419340, &
            -0.608720,-1.719643,-3.237604,2.514851,-1.893359,1.763173,2.473273,0.224786, &
            -0.883622,-1.590972,-3.545142,2.375192,-1.777216,1.769114,2.789658,-0.012718, &
            -0.989111,-1.011398,-3.679526,2.636714,-1.963526,1.907110,2.673442,-0.209669, &
            -0.875799,-0.385869,-4.295033,2.825316,-2.172274,2.130735,2.586654,-0.081755, &
            -1.195948,-0.338912,-4.687331,2.511157,-2.633932,2.242612,2.378787,-0.190503, &
            -1.878438,-0.591732,-5.295056,2.039987,-3.038684,2.781989,2.034273,-0.835210, &
            -4.771741,-2.292407,-8.065844,-0.117202,-5.782123,5.173293,-0.411712,-3.949985, &
            -4.171613,-1.599293,-6.763277,1.974130,-5.724151,4.974837,0.306176,-3.287323, &
            -4.295286,-4.475488,-3.720635,3.075165,-5.590934,3.273547,0.046386,-2.452796, &
            -3.196733,-4.023701,-1.778269,3.261389,-4.237298,1.253890,-0.399082,-1.487893, &
            -3.207579,-4.029521,-0.845229,2.449604,-4.018549,-0.675716,-0.902139,-1.474289, &
            -1.961785,-3.143171,-0.277799,2.634877,-2.667696,-1.771554,-0.720952,-1.130497, &
            -1.214567,-1.516272,-0.305649,2.110081,-1.532512,-0.771793,-0.031274,-1.270397, &
            -1.208026,-1.095458,-0.040635,1.839050,-1.009888,-0.429411,0.100767,-1.004636, &
            -0.896392,-0.943840,-0.106989,1.772915,-1.218202,-0.386250,-0.272468,-0.582159, &
            -1.327352,-1.420835,-0.277016,1.899241,-1.302913,0.268170,-0.235887,-0.407096, &
            0.012860,-0.009068,-0.432200,0.853739,0.243546,0.060275,0.961002,-0.351844, &
            -0.055930,0.054795,-0.779522,0.759539,-0.144252,0.235499,0.989934,-0.816529, &
            0.082001,0.305044,-0.755888,0.328961,-0.344406,0.617040,0.701277,-0.731199, &
            -0.208174,0.520676,-0.793371,0.305069,-0.124548,0.387261,0.707400,-1.107450, &
            -0.003228,0.401971,-1.103778,0.252520,-0.407465,0.526913,0.414628,-1.023589, &
            -0.210914,0.753535,-0.901869,0.129935,-0.768951,0.777805,0.287634,-1.141994, &
            -0.424456,0.504899,-1.243039,-0.257991,-0.727139,1.048530,0.308592,-0.830694, &
            -0.329113,0.627231,-1.342697,-0.224813,-0.434638,0.855730,0.359492,-0.879136, &
            0.061645,0.309742,-1.652052,-0.403251,-0.930032,1.522826,0.387975,-1.295867, &
            -0.367861,-0.253282,-1.495772,-0.306267,-1.534138,1.131840,-0.477317,-1.812533, &
            0.529505,0.322585,-0.656558,1.063134,-0.665461,0.650311,0.424939,-0.866333, &
            0.537585,0.571450,-0.159101,1.008170,-0.687318,0.324340,0.505988,-0.629615, &
            0.275749,0.792708,-0.076561,0.858394,-0.550478,-0.003813,0.589444,-0.417589, &
            0.083216,0.294618,-0.113513,1.048021,-0.722220,0.430972,0.372407,-0.316110, &
            0.116885,0.385489,0.197169,0.905197,-0.568535,0.420785,0.527712,-0.023492, &
            -0.213124,-0.020909,0.189371,0.186573,-0.933048,1.023449,0.120278,-0.192872, &
            0.502469,0.165648,0.327283,0.407956,-0.716764,0.403519,0.367028,0.235723, &
            0.113753,-0.289707,-0.028859,-0.069278,-0.583027,0.097175,0.059028,0.064929, &
            0.175298,-0.094833,0.108962,0.129750,0.238581,0.247989,-0.096990,0.039007, &
            0.000551,-0.131354,0.150815,0.158744,-0.066700,0.072445,-0.184725,0.179501, &
            0.043863,0.071644,-0.051736,0.142956,0.027574,-0.176921,0.085813,-0.175458, &
            0.037850,-0.122081,0.023394,-0.057799,-0.046889,-0.096867,-0.064175,-0.009815, &
            0.043026,-0.018861,0.052623,-0.153832,0.015849,0.222974,0.138734,-0.102130, &
            -0.011968,-0.388441,-0.044843,-0.013601,-0.128437,0.135545,0.138273,0.133730, &
            -0.136432,-0.097347,-0.149283,0.155058,0.081391,0.082197,0.000662,0.084239, &
            -0.229138,0.288859,0.017975,0.121619,0.094001,0.542764,-0.067177,-0.326055, &
            0.017455,0.099697,0.033706,0.088484,0.479515,0.649858,0.155856,0.026023, &
            -0.967965,-0.513237,-0.073560,-0.181502,-0.099184,0.876431,0.168558,-0.209809, &
            -0.488202,0.064263,0.206071,-0.089616,0.379393,-0.399813,0.137454,0.411481, &
            -0.868499,-0.851354,0.143142,-0.365698,-0.013122,-0.702692,0.433354,0.223549, &
            -0.802581,0.131084,0.198267,0.005657,0.062964,-0.570595,0.401241,0.207317, &
            -0.238961,0.334796,0.093520,-0.175174,0.003869,-0.271786,-0.020155,0.052825, &
            0.514283,-0.578461,0.042318,0.022564,0.383577,-0.875550,0.048377,-0.168227, &
            0.592196,-0.499253,-0.434783,-0.716407,-0.031848,-1.238029,-0.282255,-0.920045, &
            0.041763,0.147412,-0.703078,-0.678297,0.046892,0.199483,0.307094,-1.287059, &
            0.515077,0.564914,-0.272273,-0.348592,-0.111460,-0.531713,0.109889,-0.950870, &
            -0.280328,-0.012050,-0.118243,0.043962,-0.041978,-0.137088,0.078674,-0.290847, &
            -0.011579,0.008310,0.129178,0.005183,-0.077487,0.072530,0.222341,-0.054272, &
            -0.192576,-0.007330,0.188298,-0.131931,0.011745,-0.161531,0.137273,-0.248932, &
            0.016135,0.025652,0.317157,-0.033999,-0.170904,0.053076,-0.042352,-0.108476, &
            0.028556,-0.486514,0.248237,-0.043782,0.069313,-0.052084,-0.313286,-0.183836, &
            -0.192055,-0.593511,-0.051723,-0.363771,0.215925,-0.214024,0.052831,-0.184309, &
            -0.035033,-0.955536,0.361601,-0.256685,-0.002965,-0.063224,-0.259454,-0.081596, &
            0.245287,-0.864676,0.319108,-0.365327,0.022003,-0.062143,-0.236207,0.072834, &
            0.117409,-0.007542,0.954139,-0.379261,0.355789,-0.062445,-0.471762,0.655991, &
            -0.147869,-0.955990,0.777431,-1.206800,0.532649,-0.322212,-0.603045,0.597863, &
            -0.545231,-0.164950,0.082321,-1.545500,0.386912,-0.423214,-0.736695,0.162178, &
            -0.113626,0.185940,0.199939,-0.848035,0.516999,-0.451235,-0.410809,0.194178, &
            0.315888,0.081370,0.320401,-0.647577,0.455539,0.458518,-0.356187,-0.073806, &
            0.361167,0.447540,0.383929,-0.742075,0.119660,0.366778,-0.232302,0.131197, &
            0.595506,0.571548,0.184203,-0.146065,-0.001375,-0.011339,-0.244709,-0.289589, &
            0.331217,0.150459,0.257802,0.024028,0.032359,0.418033,-0.351798,-0.652864, &
            0.624624,0.338017,0.400780,-0.158731,0.217519,0.393969,-0.110096,-0.461927, &
            0.478745,0.392866,0.312943,-0.154384,-0.087433,0.641522,-0.237956,-0.607715, &
            -0.179342,0.217427,-0.083136,-0.092073,0.163153,-0.099452,-0.019637,-0.042859, &
            0.082693,-0.118940,0.003701,0.012461,0.016394,-0.034951,-0.086568,-0.077775, &
            -0.080998,-0.110304,-0.012599,-0.128442,0.092935,-0.050517,-0.033970,-0.115037, &
            -0.034823,-0.233663,0.023224,-0.100388,0.059455,0.029514,-0.042243,-0.109792, &
            -0.068095,-0.937772,-0.036518,0.026728,0.059696,0.036627,0.044364,-0.042613, &
            -0.075313,-1.351238,0.041239,-0.003872,-0.088481,0.023951,0.187868,-0.044041, &
            -0.050239,-2.068362,-0.013216,0.036114,0.006126,0.032865,0.055273,0.030764, &
            -0.187150,-1.777250,-0.108729,0.095232,-0.017921,-0.010455,0.227359,0.163765, &
            -0.013876,0.130555,0.076297,-0.210417,-0.071320,0.446576,0.273940,0.100902, &
            -0.045119,-0.151167,0.050111,-0.178587,0.075194,0.244170,0.076322,-0.147572, &
            -0.126604,0.153406,-0.011055,0.126092,0.091462,-0.151072,-0.094016,-0.192293, &
            0.063447,0.081662,0.015304,-0.092026,-0.010461,0.040306,-0.063145,0.214894, &
            0.131747,-0.166019,0.001804,-0.184118,-0.271784,-0.015786,0.243980,0.363397, &
            0.076762,1.681522,0.035348,-0.171067,-0.466631,-0.137957,0.561314,0.566123, &
            0.016327,0.552997,-0.005750,0.167573,-0.048887,0.115042,0.123168,-0.252351, &
            -0.127226,-0.724327,-0.003951,-0.200583,0.049077,-0.069206,0.115438,0.069541, &
            -0.015068,-0.916243,-0.001512,-0.180807,0.011803,-0.054625,0.163007,-0.109212, &
            0.005471,-0.606347,0.073374,-0.119471,0.077151,0.291235,-0.058951,-0.368031 &
            /),(/8,126/))
real, dimension(2,8) :: hidden1 = &
  Reshape((/-1.696152,2.002429, &
            1.383967,2.132949, &
            -0.116104,5.142089, &
            -2.172384,-1.408764, &
            -0.142701,3.574486, &
            0.781649,-1.128706, &
            -1.289781,0.349048, &
            -0.422334,2.325981 &
            /),(/2,8/))
real, dimension(1,2) :: hidden2 = &
  Reshape((/-1.967999,1.70037/),(/1,2/))
real, dimension(8) :: bias1 = &
(/0.649883,0.924679,1.418928,0.854843,1.118972,-0.928046,1.022479,0.321773/)
real, dimension(2) :: bias2 = &
(/0.121254,-0.37965/)
real, dimension(1) :: bias3 = &
(/0.126869/)
contains
subroutine fnet_antioch_initall()
end subroutine fnet_antioch_initall
subroutine fnet_antioch_engine(inarray, outarray, init)
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
end subroutine fnet_antioch_engine
end module fnet_antioch