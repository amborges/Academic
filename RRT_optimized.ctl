float[3][3] calc_sat_adjust_matrix 
( 
	input varying float sat,
	input varying float rgb2Y[3]
)
{
	float M[3][3];
	M[0][0] = (1.0 - sat) * rgb2Y[0] + sat;
	M[1][0] = (1.0 - sat) * rgb2Y[0];
	M[2][0] = (1.0 - sat) * rgb2Y[0];
	M[0][1] = (1.0 - sat) * rgb2Y[1];
	M[1][1] = (1.0 - sat) * rgb2Y[1] + sat;
	M[2][1] = (1.0 - sat) * rgb2Y[1];
	M[0][2] = (1.0 - sat) * rgb2Y[2];
	M[1][2] = (1.0 - sat) * rgb2Y[2];
	M[2][2] = (1.0 - sat) * rgb2Y[2] + sat;
	M = transpose_f33(M);	
	return M;
}
struct SplineMapPoint
{
	float x;
	float y;
};
struct SegmentedSplineParams_c5
{
	float coefsLow[6];
	float coefsHigh[6];
	SplineMapPoint minPoint;
	SplineMapPoint midPoint;
	SplineMapPoint maxPoint;
	float slopeLow;
	float slopeHigh;
};
const float TINY = 1e-10;
const float RRT_GLOW_GAIN = 0.05;
const float RRT_GLOW_MID = 0.08;
const float RRT_RED_SCALE = 0.82;
const float RRT_RED_PIVOT = 0.03;
const float RRT_RED_WIDTH = 135.;
const float RRT_SAT_FACTOR = 0.96;
const float M[ 3][ 3] = {
	{  0.5, -1.0, 0.5 },
	{ -1.0,  1.0, 0.5 },
	{  0.5,  0.0, 0.0 }
};
const SegmentedSplineParams_c5 RRT_PARAMS =
{
	{ -4.0000000000, -4.0000000000, -3.1573765773, -0.4852499958, 1.8477324706, 1.8477324706 },
	{ -0.7185482425, 2.0810307172, 3.6681241237, 4.0000000000, 4.0000000000, 4.0000000000 },
	{ 5.49316e-06, 0.0001},
	{ 0.18,				4.8},
	{ 47185.9, 10000.},
	0.0,
	0.0
};

const float RRT_SAT_MAT[3][3] = {{
	0.970889151096343994140625,
	0.01088915579020977020263671875,
	0.01088915579020977020263671875},
{
	0.02696328423917293548583984375,
	0.9869632720947265625,
	0.02696328423917293548583984375},
{
	0.0021475818939507007598876953125,
	0.0021475818939507007598876953125,
	0.962147533893585205078125}
};

const float AP0_2_AP1_MAT[4][4] = {{
	1.45143926143646240234375,
	-0.076553761959075927734375,
	0.0083161294460296630859375,
	0.},
{
	-0.2365107238292694091796875,
	1.1762297153472900390625,
	-0.006032462231814861297607421875,
	0.},
{
	-0.21492855250835418701171875,
	-0.09967593848705291748046875,
	0.997716367244720458984375,
	0.},
{
	0.,
	0.,
	0.,
	1.}
};


const float AP1_2_AP0_MAT[4][4] = {{
	0.695452213287353515625,
	0.044794581830501556396484375,
	-0.0055258679203689098358154296875,
	0.},
{
	0.1406786739826202392578125,
	0.859671115875244140625,
	0.004025223664939403533935546875,
	0.},
{
	0.16386903822422027587890625,
	0.095534317195415496826171875,
	1.001500606536865234375,
	0.},
{
	0.,
	0.,
	0.,
	1.}
};


float min( float a, float b)
{
	if (a < b)
		return a;
	else
		return b;
}

float max( float a, float b)
{
	if (a > b)
		return a;
	else
		return b;
}

float min_f3( float a[3])
{
	return min( a[0], min( a[1], a[2]));
}

float max_f3( float a[3])
{
	return max( a[0], max( a[1], a[2]));
}

float rgb_2_saturation( float rgb[3])
{
	return ( max( max_f3(rgb), TINY) - max( min_f3(rgb), TINY)) / max( max_f3(rgb), 1e-2);
}

float rgb_2_yc( float rgb[3], float ycRadiusWeight = 1.75)
{
	float r = rgb[0]; 
	float g = rgb[1]; 
	float b = rgb[2];
	float chroma = sqrt(b*(b-g)+g*(g-r)+r*(r-b));
	return ( b + g + r + ycRadiusWeight * chroma) / 3.;
}

int sign( float x)
{
	int y;
	if (x < 0) { 
		y = -1;
	} else if (x > 0) {
		y = 1;
	} else {
		y = 0;
	}
	return y;	
}

float sigmoid_shaper( float x)
{
	float t = max( 1. - fabs( x / 2.), 0.);
	float y = 1. + sign(x) * (1. - t * t);
	return y / 2.;
}

float glow_fwd( float ycIn, float glowGainIn) //CHANGED
{
	float glowGainOut;
	if (ycIn <= 0.0533333333) { //CHANGED
		glowGainOut = glowGainIn;
	} else if ( ycIn >= 0.16) { //CHANGED
		glowGainOut = 0.;
	} else {
		glowGainOut = glowGainIn * (0.08 / ycIn - 0.5); //CHANGED
	}
	return glowGainOut;
}

float rgb_2_hue( float rgb[3]) 
{
	float hue;
	if (rgb[0] == rgb[1] && rgb[1] == rgb[2]) {
		hue = FLT_NAN;
	} else {
			//180. / M_PI
		//hue = (57.29577951308232286464772187173366546630859375) * atan2( sqrt(3)*(rgb[1]-rgb[2]), 2*rgb[0]-rgb[1]-rgb[2]);
		hue = (180. / M_PI) * atan2( sqrt(3)*(rgb[1]-rgb[2]), 2*rgb[0]-rgb[1]-rgb[2]);
	}
	if (hue < 0.) hue = hue + 360.;
	//float hueCentered = hue;
	//if (hueCentered < -180.) hueCentered = hueCentered + 360.;
	if (hue > 180.) hue = hue - 360.;
	return hue;
}

float cubic_basis_shaper
( 
	varying float x, 
	varying float w
)
{
	float M[4][4] = { { -0.1666666666,	0.5, 					-0.5,					0.1666666666 },
									{		0.5, 						-1.,					0.5,					0. },
									{ 	-0.5,						0.,						0.5,					0. },
									{		0.1666666666,		0.6666666666,	0.1666666666,	0. } }; //CHANGED
	float knots[5] = { -w/2.,
										 -w/4.,
										 0.,
										 w/4.,
										 w/2. };
	float y;
	if ((x > knots[0]) && (x < knots[4])) {
		float knot_coord = (x - knots[0]) * 4./w;	
		int j = knot_coord;
		float t = knot_coord - j;
		float monomials[4] = { t*t*t, t*t, t, 1. };
		if ( j == 3) {
			y = monomials[0] * M[0][0] + monomials[1] * M[1][0] + 
				monomials[2] * M[2][0] + monomials[3] * M[3][0];
		} else if ( j == 2) {
			y = monomials[0] * M[0][1] + monomials[1] * M[1][1] + 
				monomials[2] * M[2][1] + monomials[3] * M[3][1];
		} else if ( j == 1) {
			y = monomials[0] * M[0][2] + monomials[1] * M[1][2] + 
				monomials[2] * M[2][2] + monomials[3] * M[3][2];
		} else if ( j == 0) {
			y = monomials[0] * M[0][3] + monomials[1] * M[1][3] + 
				monomials[2] * M[2][3] + monomials[3] * M[3][3];
		} else {
			y = 0.0;
		}
	}
	return y * 1.5; //CHANGED
}

float clamp( float in, float clampMin, float clampMax)
{
	return max( clampMin, min(in, clampMax));
}

float[3] clamp_f3( float in[3], float clampMin, float clampMax)
{
	float out[3];
	out[0] = clamp( in[0], clampMin, clampMax);
	out[1] = clamp( in[1], clampMin, clampMax);
	out[2] = clamp( in[2], clampMin, clampMax);	
	return out;
}

float segmented_spline_c5_fwd
( 
	varying float x,
	varying SegmentedSplineParams_c5 C = RRT_PARAMS
)
{
	const int N_KNOTS_LOW = 4;
	const int N_KNOTS_HIGH = 4;
	float xCheck = x;
	if (xCheck <= 0.0) xCheck = 6.103515625e-05;//pow(2., -14.);
	
	float logx = log10( xCheck);
	float logy;
	if ( logx <= -5.2601776123046875) { //log10(C.minPoint.x) ) { 
		logy = -4.;
	} else if (( logx > -5.2601776123046875 ) && ( logx < -0.74472749233245849609375 )) {
		//float knot_coord = (N_KNOTS_LOW-1) * (logx-log10(C.minPoint.x))/(log10(C.midPoint.x)-log10(C.minPoint.x));
		float knot_coord = 3. * (logx+5.2601776123046875) / 4.51545011997222900390625;//(-0.74472749233245849609375+5.2601776123046875);
		int j = knot_coord;
		float t = knot_coord - j;
		float cf[ 3] = { C.coefsLow[ j], C.coefsLow[ j + 1], C.coefsLow[ j + 2]};
		float monomials[ 3] = { t * t, t, 1. };
		logy = dot_f3_f3( monomials, mult_f3_f33( cf, M));
	} else if (( logx >= -0.74472749233245849609375 ) && ( logx < 4.673812389373779296875 )) {
		//float knot_coord = (N_KNOTS_HIGH-1) * (logx-log10(C.midPoint.x))/(log10(C.maxPoint.x)-log10(C.midPoint.x));
		float knot_coord = 3. * (logx+0.74472749233245849609375)/(5.41853988170623779296875);
		int j = knot_coord;
		float t = knot_coord - j;
		float cf[ 3] = { C.coefsHigh[ j], C.coefsHigh[ j + 1], C.coefsHigh[ j + 2]};
		float monomials[ 3] = { t * t, t, 1. };
		logy = dot_f3_f3( monomials, mult_f3_f33( cf, M));
	} else {
		logy = 4.;
	}
	return pow10(logy);
}

void main 
( 
	input varying float rIn,
	input varying float gIn,
	input varying float bIn,
	input varying float aIn,
	output varying float rOut,
	output varying float gOut,
	output varying float bOut,
	output varying float aOut
)
{
	float aces[3] = {rIn, gIn, bIn};
	float saturation = rgb_2_saturation( aces);
	float ycIn = rgb_2_yc( aces);
	float s = sigmoid_shaper( (saturation - 0.4) / 0.2);
	float addedGlow = 1. + glow_fwd( ycIn, RRT_GLOW_GAIN * s); //CHANGED
	aces = mult_f_f3( addedGlow, aces);
	float centeredHue = rgb_2_hue( aces);
	float hueWeight = cubic_basis_shaper( centeredHue, RRT_RED_WIDTH);
	aces[0] = aces[0] + hueWeight * saturation * (RRT_RED_PIVOT - aces[0]) * (1. - RRT_RED_SCALE);
	aces = clamp_f3( aces, 0., HALF_POS_INF);
	float rgbPre[3] = mult_f3_f44( aces, AP0_2_AP1_MAT);
	rgbPre = clamp_f3( rgbPre, 0., HALF_MAX);
	rgbPre = mult_f3_f33( rgbPre, RRT_SAT_MAT);
	float rgbPost[3];
	
	rgbPost[0] = segmented_spline_c5_fwd( rgbPre[0]);
	rgbPost[1] = segmented_spline_c5_fwd( rgbPre[1]);
	rgbPost[2] = segmented_spline_c5_fwd( rgbPre[2]);
	
	float rgbOces[3] = mult_f3_f44( rgbPost, AP1_2_AP0_MAT);
	rOut = rgbOces[0];
	gOut = rgbOces[1];
	bOut = rgbOces[2];
	aOut = aIn;
}
