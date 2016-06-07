const Chromaticities ACES_PRI =
{
	{0.713,	0.293},
	{0.165,	0.830},
	{0.128,	0.044},
	{0.32168,	0.33767}
};
const Chromaticities REC2020_PRI = 
{
	{0.70800, 0.29200},
	{0.17000, 0.79700},
	{0.13100, 0.04600},
	{0.31270, 0.32900}
};
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);
const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);
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
	offset_scaled[0] = (SCALE * rgbOut[0]) + BPC;
	offset_scaled[1] = (SCALE * rgbOut[1]) + BPC;
	offset_scaled[2] = (SCALE * rgbOut[2]) + BPC;
	float tmp[3];
	tmp[0] = max( (offset_scaled[0] - OUT_BP)/(OUT_WP_MAX - OUT_BP), 0.);
	tmp[1] = max( (offset_scaled[1] - OUT_BP)/(OUT_WP_MAX - OUT_BP), 0.);
	tmp[2] = max( (offset_scaled[2] - OUT_BP)/(OUT_WP_MAX - OUT_BP), 0.);
	float tmp2[3] = clamp_f3(tmp,0.,65000.0); 
	//if(tmp2[1]>1.0) print("SCALE: ",SCALE, " tmp2[1]= ",tmp2[1],"\n");
	float cctf[3] = clamp_f3(tmp,0.,1.0); 
	cctf[0] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp2[0]);
	cctf[1] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp2[1]);
	cctf[2] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp2[2]); 
	float outputCV[3] = clamp_f3( cctf, 0., pow( 2, BITDEPTH)-1);
	outputCV = mult_f_f3( 1./(pow(2,BITDEPTH)-1), outputCV);
	rOut = outputCV[0];
	gOut = outputCV[1];
	bOut = outputCV[2];
	//aOut = aIn;
}
