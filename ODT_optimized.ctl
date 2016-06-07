const float OCES_PRI_2_XYZ_MAT[4][4] = {{
	0.66245424747467041015625,
	0.2722287476062774658203125,
	-0.005574661307036876678466796875,
	0.},
{
	0.1340042054653167724609375,
	0.674081742763519287109375,
	0.0040607415139675140380859375,
	0.},
{
	0.1561876833438873291015625,
	0.053689517080783843994140625,
	1.0103390216827392578125,
	0.},
{
	0.,
	0.,
	0.,
	1.}
};

const float XYZ_2_DISPLAY_PRI_MAT[4][4] = {{
	1.71665096282958984375,
	-0.666684329509735107421875,
	0.01763986051082611083984375,
	0.},
{
	-0.3556707203388214111328125,
	1.61648118495941162109375,
	-0.0427706241607666015625,
	0.},
{
	-0.2533662319183349609375,
	0.0157685391604900360107421875,
	0.9421031475067138671875,
	0.},
{
	0.,
	0.,
	0.,
	1.}
};

const float OUT_BP = 0.0;
const float OUT_WP_MAX = 10000.0;
const unsigned int BITDEPTH = 16;
const unsigned int CV_BLACK = 4096;
const unsigned int CV_WHITE = 60160;
const float BPC = 0.;
const float SCALE = 1.;

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
float PQ10000_r( float L)
{
	float V;
	V = pow((0.8359375+ 18.8515625*pow((L),0.1593017578))/(1+18.6875*pow((L),0.1593017578)),78.84375);
	return V;
}

void main 
(
	input varying float rIn, 
	input varying float gIn, 
	input varying float bIn, 
	output varying float rOut,
	output varying float gOut,
	output varying float bOut 
)
{
	float oces[3] = {rIn, gIn, bIn};
	float XYZ[3] = mult_f3_f44( oces, OCES_PRI_2_XYZ_MAT);
	float rgbOut[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT); 
	float offset_scaled[3];
	offset_scaled[0] = rgbOut[0];
	offset_scaled[1] = rgbOut[1];
	offset_scaled[2] = rgbOut[2];
	float tmp[3];
	tmp[0] = max( (offset_scaled[0])/(OUT_WP_MAX), 0.);
	tmp[1] = max( (offset_scaled[1])/(OUT_WP_MAX), 0.);
	tmp[2] = max( (offset_scaled[2])/(OUT_WP_MAX), 0.);
	float tmp2[3] = clamp_f3(tmp,0.,65000.0); 
	float cctf[3] = clamp_f3(tmp,0.,1.0); 
	cctf[0] = CV_BLACK + (56064) * PQ10000_r(tmp2[0]);
	cctf[1] = CV_BLACK + (56064) * PQ10000_r(tmp2[1]);
	cctf[2] = CV_BLACK + (56064) * PQ10000_r(tmp2[2]);  
	float outputCV[3] = clamp_f3( cctf, 0., 65535.);
	outputCV = mult_f_f3( 1.52590218966964217585380314545773217105306684970855712890625e-05, outputCV);
	rOut = outputCV[0];
	gOut = outputCV[1];
	bOut = outputCV[2];
}
