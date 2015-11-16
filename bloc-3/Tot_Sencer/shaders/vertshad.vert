# version 330 core

in vec3 vertex;
in vec3 normal;

in vec3 matamb;
in vec3 matdiff;
in vec3 matspec;
in float matshin;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 TG;

// Valors per als components que necessitem dels focus de llum
uniform vec3 colFocus = vec3(0.8, 0.8, 0.8);
vec3 llumAmbient = vec3(0.2, 0.2, 0.2);
uniform vec3 posFocus = vec3(0, 0, 0);  // en SCA

out vec3 fcolor;

vec3 Lambert (vec3 NormSCO, vec3 L) 
{
    // S'assumeix que els vectors que es reben com a paràmetres estan normalitzats

    // Inicialitzem color a component ambient
    vec3 colRes = llumAmbient * matamb;

    // Afegim component difusa, si n'hi hax
    if (dot (L, NormSCO) > 0)
      colRes = colRes + colFocus * matdiff * dot (L, NormSCO);
    return (colRes);
}

vec3 Phong (vec3 NormSCO, vec3 L, vec4 vertSCO) 
{
    // Els vectors estan normalitzats

    // Inicialitzem color a Lambert
    vec3 colRes = Lambert (NormSCO, L);

    // Calculem R i V
    if (dot(NormSCO,L) < 0)
      return colRes;  // no hi ha component especular

    vec3 R = reflect(-L, NormSCO); // equival a: normalize (2.0*dot(NormSCO,L)*NormSCO - L);
    vec3 V = normalize(-vertSCO.xyz);

    if ((dot(R, V) < 0) || (matshin == 0))
      return colRes;  // no hi ha component especular
    
    // Afegim la component especular
    float shine = pow(max(0.0, dot(R, V)), matshin);
    return (colRes + matspec * colFocus * shine); 
}

void main()
{

    // LAMBERT SENSE BRILLO
    fcolor = matdiff;

    gl_Position = proj * view * TG * vec4 (vertex, 1.0);

    vec4 L = view * TG * vec4 (vertex, 1.0);

    // La posicio del focus de llum ha d'estar en SCO.
    vec4 posFocusNormal = vec4 (posFocus, 1.0);
    L = posFocusNormal - L;

    // El vector normal a SCO.
    mat3 NormalMatrix = inverse(transpose(mat3(view*TG)));
    //vec3 NormSCO = normalize(NormalMatrix*normal);			// NO BRILLANT
    vec3 NormSCO = NormalMatrix*normal;					// BRILLANT
    
    fcolor = Lambert(NormSCO, normalize(L.xyz));
    //fcolor = Phong(NormSCO, normalize(L.xyz), vec4 (vertex, 1.0));

}
