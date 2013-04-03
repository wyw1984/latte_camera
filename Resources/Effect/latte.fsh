/*
 Created by Xuan Dung Bui
 */

precision highp float;

varying highp vec2 textureCoordinate;
varying highp vec2 blendCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D toneCurveTexture;
uniform sampler2D inputBlendTexture;

uniform lowp float vignfade; //f-stops till vignete fades
uniform lowp float brightness;

uniform lowp float clearness;
uniform lowp float saturation;
uniform lowp float aspectratio;

uniform lowp float toneIntensity;
uniform lowp float blendIntensity;

lowp float vignin = 0.0; //vignetting inner border
lowp float vignout = 0.5; //vignetting outer border

float aperture = 180.0;
const float PI = 3.1415926535;
const highp vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);


float vignette()
{
    highp float dist = distance(vec2(textureCoordinate.x, (textureCoordinate.y * aspectratio + 0.5 - 0.5 * aspectratio)), vec2(0.5,0.5));
    dist = smoothstep(vignout+vignfade, vignin+vignfade, dist);
    return clamp(dist,0.0,1.0);
}

void main()
{
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);

    lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
    lowp float average = (textureColor.r + textureColor.g + textureColor.b)/3.0;
    lowp vec3 greyScaleColor = vec3(luminance);
    // lowp vec3 averageColor = vec3(average);

    // Brightness
    textureColor.rgb += vec3(brightness);

    // Contrast
    //vec3 conColor = mix(averageColor, satColor, 1.0);
    
    // textureColor.rgb = conColor;

    // Vignette
    textureColor.rgb *= vignette();

    // Overlay
    if (clearness > 0.0) {
        if (textureColor.r < 0.5) {
            textureColor.r = 2.0 * luminance * textureColor.r * clearness + textureColor.r * (1.0 - clearness);
        } else {
            textureColor.r = (1.0 - 2.0 * (1.0 - textureColor.r) * (1.0 - luminance)) * clearness + textureColor.r * (1.0 - clearness);
        }
        if (textureColor.g < 0.5) {
            textureColor.g = 2.0 * luminance * textureColor.g * clearness + textureColor.g * (1.0 - clearness);
        } else {
            textureColor.g = (1.0 - 2.0 * (1.0 - textureColor.g) * (1.0 - luminance)) * clearness + textureColor.g * (1.0 - clearness);
        }
        if (textureColor.b < 0.5) {
            textureColor.b = 2.0 * luminance * textureColor.b * clearness + textureColor.b * (1.0 - clearness);
        } else {
            textureColor.b = (1.0 - 2.0 * (1.0 - textureColor.b) * (1.0 - luminance)) * clearness + textureColor.b * (1.0 - clearness);
        }
    }

    // Blending
    mediump vec4 textureBlend = texture2D(inputBlendTexture, blendCoordinate);
    textureBlend *= blendIntensity;
    mediump vec4 whiteColor = vec4(1.0);
    textureColor = whiteColor - ((whiteColor - textureBlend) * (whiteColor - textureColor));

    // Tone Curve Mapping
    lowp float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
    lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
    lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
     
    textureColor = vec4(mix(textureColor.rgb, vec3(redCurveValue, greenCurveValue, blueCurveValue), toneIntensity), textureColor.a);

    // Saturation
    luminance = dot(textureColor.rgb, luminanceWeighting);
    textureColor = vec4(mix(vec3(luminance), textureColor.rgb, saturation), textureColor.a);
    // End
    gl_FragColor = textureColor;
}