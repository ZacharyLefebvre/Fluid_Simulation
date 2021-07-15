using UnityEngine;

public class FluidSimulation : MonoBehaviour
{
    public enum BorderType
    {
        Blocking,
        Wrapping,
        Open
    }

    [Header("Main parameters")]
    [Range(1, 500)] public int JacobiIterations = 100;
    [Range(0.0f, 1.0f)] public float DensityAttenuation = 0.15f;
    [Range(0.0f, 1.0f)] public float VelocityAttenuation = 0.0f;
    public BorderType HorizontalBorder = BorderType.Blocking;
    public BorderType VerticalBorder = BorderType.Blocking;

    [Header("Spawn")]
    [Range(0.0f, 1.0f)] public float SmokeDensity = 0.25f;
    [Range(0.0f, 0.25f)] public float SpawnRadius = 0.1f;
    [Range(-1.0f, 1.0f)] public float DivergenceIntensity = 0.25f;
    [Range(0.0f, 10.0f)] public float MaxDensity = 5.0f;

    [Range(0.0f, 2.0f)] public float InjectFromVorticity = 0.0f;
    [Range(0.0f, 2.0f)] public float InjectFromDivergence = 0.0f;
    [Range(0.0f, 2.0f)] public float InjectFromPressure = 0.0f;

    [Header("Noise")]
    public float NoiseScale = 1.0f;
    public float NoiseAnimationSpeed = 1.0f;
    [Range(0.0f, 5.0f)] public float DensityAttenuationNoise = 0.5f;
    [Range(0.0f, 5.0f)]public float ConstantVelocityNoise = 0.5f;

    public float NoiseInjectionScale = 1.0f;
    public float NoiseInjectionAnimationSpeed = 1.0f;
    [Range(0.0f, 1.0f)] public float NoiseInjectionIntensity = 0.5f;

    [Header("Forces")]
    [Range(-15.0f, 15.0f)] public float VelocityBoost = 2.0f; // mouse movement
    public Vector2 ConstantVelocity = Vector2.zero;

    [Header("Vorticity")]
    [Range(0.0f, 1.0f)] public float VorticityIntensity = 0.2f;
    [Range(0.0f, 1.0f)] public float VorticityAttenuationByDensity = 0.5f;
    [Range(0.0f, 1.0f)] public float VorticityAttenuationByVelocity = 0.5f;

    [Header("Collisions")]
    public bool UseColliderTexture = true;
    public Texture Collider;

    #region Private
    public SwappableRenderTexture velocityTexture;
    SwappableRenderTexture componentTexture; // donne la quantité de liquide
    SwappableRenderTexture pressureTexture;
    RenderTexture divergenceTexture; // détecte les dépressions / pressions sous forme de positif / négatif => calcul de l'erreur
    RenderTexture vorticityTexture;
    ComputeShader fluidSimulationCompute;
    Material meshMaterial;
    Renderer meshRenderer;

    [HideInInspector] public uint ThreadGroupSizeX;
    [HideInInspector] public uint ThreadGroupSizeY;
    [HideInInspector] public uint ThreadGroupSizeZ;
    Vector2 invTextureSize;
    Vector2 textureSize;
    Vector2 previousHitCoord = Vector2.zero;
    #endregion

    #region Const
    [HideInInspector] public int simulationSizeX = 512;
    [HideInInspector] public int simulationSizeY = 512;
    #endregion

    #region UnityFunctions
    void OnEnable()
    {
        Initialize();    
    }

    void Update()
    {
        Simulate();
    }

    private void OnDestroy()
    {
        Uninitialize();
    }
    #endregion

    #region Functions
    public void Initialize()
    {
        fluidSimulationCompute = Resources.Load<ComputeShader>("SimulationCompute");
        fluidSimulationCompute.GetKernelThreadGroupSizes(0, out ThreadGroupSizeX, out ThreadGroupSizeY, out ThreadGroupSizeZ);
        invTextureSize = new Vector2(1.0f / simulationSizeX, 1.0f / simulationSizeY);
        textureSize = new Vector2(simulationSizeX, simulationSizeY);

        componentTexture = new SwappableRenderTexture(simulationSizeX, simulationSizeY, RenderTextureFormat.RHalf, TextureWrapMode.Clamp, FilterMode.Bilinear);
        velocityTexture = new SwappableRenderTexture(simulationSizeX, simulationSizeY, RenderTextureFormat.RGHalf, TextureWrapMode.Clamp, FilterMode.Bilinear);
        pressureTexture = new SwappableRenderTexture(simulationSizeX, simulationSizeY, RenderTextureFormat.RHalf, TextureWrapMode.Clamp, FilterMode.Bilinear);
        divergenceTexture = SwappableRenderTexture.CreateRenderTexture(simulationSizeX, simulationSizeY, RenderTextureFormat.RHalf, TextureWrapMode.Clamp, FilterMode.Bilinear);
        vorticityTexture = SwappableRenderTexture.CreateRenderTexture(simulationSizeX, simulationSizeY, RenderTextureFormat.RHalf, TextureWrapMode.Clamp, FilterMode.Bilinear);

        meshRenderer = GetComponent<MeshRenderer>();
        meshMaterial = meshRenderer.material;
    }

    private void Uninitialize()
    {
        componentTexture.Release();
        velocityTexture.Release();
        pressureTexture.Release();
        divergenceTexture.Release();
        vorticityTexture.Release();
    }

    public void OnRestart()
    {
        Uninitialize();
        Initialize();

        fluidSimulationCompute.SetTexture(6, "outComponentTexture", componentTexture.Write);
        fluidSimulationCompute.SetTexture(6, "outVelocityTexture", velocityTexture.Write);
        fluidSimulationCompute.SetTexture(6, "outDivergenceTexture", divergenceTexture);
        fluidSimulationCompute.SetTexture(6, "outPressureTexture", pressureTexture.Write);
        fluidSimulationCompute.SetTexture(6, "outVorticityTexture", vorticityTexture);

        fluidSimulationCompute.Dispatch(6, simulationSizeX / (int)ThreadGroupSizeX, simulationSizeY / (int)ThreadGroupSizeY, 1);

        velocityTexture.Swap();
        componentTexture.Swap();
        pressureTexture.Swap();

        fluidSimulationCompute.SetTexture(6, "outComponentTexture", componentTexture.Write);
        fluidSimulationCompute.SetTexture(6, "outVelocityTexture", velocityTexture.Write);
        fluidSimulationCompute.SetTexture(6, "outDivergenceTexture", divergenceTexture);
        fluidSimulationCompute.SetTexture(6, "outPressureTexture", pressureTexture.Write);
        fluidSimulationCompute.SetTexture(6, "outVorticityTexture", vorticityTexture);

        fluidSimulationCompute.Dispatch(6, simulationSizeX / (int)ThreadGroupSizeX, simulationSizeY / (int)ThreadGroupSizeY, 1);

        velocityTexture.Swap();
        componentTexture.Swap();
        pressureTexture.Swap();
    }
    public void Simulate()
    {
        Vector2 uvHit = Vector2.zero;
        Vector2 injectedVelocity = Vector2.zero;
        float injectedDivergence = 0.0f;
        bool inject = false;

        if ((Input.GetMouseButton(0) || Input.GetMouseButton(1)) && Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out RaycastHit hit))
        {
            uvHit = hit.textureCoord;
            if (Input.GetMouseButton(0))
            {
                inject = true;
                injectedVelocity = (uvHit - previousHitCoord) * (previousHitCoord == Vector2.zero? 0.0f : 1.0f);
            }
            if (Input.GetMouseButton(1))
                injectedDivergence = DivergenceIntensity;

            previousHitCoord = uvHit;
        }
        else
        {
            previousHitCoord = Vector2.zero;
        }

        if (HorizontalBorder == BorderType.Wrapping)
        {
            divergenceTexture.wrapModeU = TextureWrapMode.Repeat;
            vorticityTexture.wrapModeU = TextureWrapMode.Repeat;
            componentTexture.wrapModeU = TextureWrapMode.Repeat;
            velocityTexture.wrapModeU = TextureWrapMode.Repeat;
            pressureTexture.wrapModeU = TextureWrapMode.Repeat;
        }
        else
        {
            divergenceTexture.wrapModeU = TextureWrapMode.Clamp;
            vorticityTexture.wrapModeU = TextureWrapMode.Clamp;
            componentTexture.wrapModeU = TextureWrapMode.Clamp;
            velocityTexture.wrapModeU = TextureWrapMode.Clamp;
            pressureTexture.wrapModeU = TextureWrapMode.Clamp;
        }

        if (VerticalBorder == BorderType.Wrapping)
        {
            divergenceTexture.wrapModeV = TextureWrapMode.Repeat;
            vorticityTexture.wrapModeV = TextureWrapMode.Repeat;
            componentTexture.wrapModeV = TextureWrapMode.Repeat;
            velocityTexture.wrapModeV = TextureWrapMode.Repeat;
            pressureTexture.wrapModeV = TextureWrapMode.Repeat;
        }
        else
        {
            divergenceTexture.wrapModeV = TextureWrapMode.Clamp;
            vorticityTexture.wrapModeV = TextureWrapMode.Clamp;
            componentTexture.wrapModeV = TextureWrapMode.Clamp;
            velocityTexture.wrapModeV = TextureWrapMode.Clamp;
            pressureTexture.wrapModeV = TextureWrapMode.Clamp;
        }

        // Advection
        fluidSimulationCompute.SetFloat("deltaTime", Time.deltaTime);
        fluidSimulationCompute.SetFloat("spawnedDensity", SmokeDensity * (inject?1.0f:0.0f));
        fluidSimulationCompute.SetFloat("spawnRadius", SpawnRadius);
        fluidSimulationCompute.SetFloat("densityAttenuation", DensityAttenuation);
        fluidSimulationCompute.SetFloat("velocityAttenuation", VelocityAttenuation);
        fluidSimulationCompute.SetInt("horizontalBorder", (int)HorizontalBorder);
        fluidSimulationCompute.SetInt("verticalBorder", (int)VerticalBorder);
        fluidSimulationCompute.SetBool("useColliderTexture", UseColliderTexture);

        fluidSimulationCompute.SetFloat("time", Time.time);
        fluidSimulationCompute.SetFloat("noiseScale", NoiseScale);
        fluidSimulationCompute.SetFloat("noiseAnimationSpeed", NoiseAnimationSpeed);
        fluidSimulationCompute.SetFloat("constantVelocityNoise", ConstantVelocityNoise);
        fluidSimulationCompute.SetFloat("densityAttenuationNoise", DensityAttenuationNoise);
        fluidSimulationCompute.SetFloat("maxDensity", MaxDensity);
        fluidSimulationCompute.SetFloat("noiseInjectionIntensity", NoiseInjectionIntensity);
        fluidSimulationCompute.SetFloat("noiseInjectionScale", NoiseInjectionScale);
        fluidSimulationCompute.SetFloat("noiseInjectionAnimationSpeed", NoiseInjectionAnimationSpeed);

        fluidSimulationCompute.SetFloat("injectFromVorticity", InjectFromVorticity);
        fluidSimulationCompute.SetFloat("injectFromDivergence", InjectFromDivergence);
        fluidSimulationCompute.SetFloat("injectFromPressure", InjectFromPressure);

        fluidSimulationCompute.SetVector("spawnPosition", uvHit);
        fluidSimulationCompute.SetVector("invTextureSize", invTextureSize);
        fluidSimulationCompute.SetVector("spawnedVelocity", injectedVelocity* VelocityBoost);
        fluidSimulationCompute.SetVector("constantVelocity", ConstantVelocity);

        fluidSimulationCompute.SetTexture(0, "inPressureTexture", pressureTexture.Read);
        fluidSimulationCompute.SetTexture(0, "inDivergenceTexture", divergenceTexture);
        fluidSimulationCompute.SetTexture(0, "inVorticityTexture", vorticityTexture);
        fluidSimulationCompute.SetTexture(0, "inComponentTexture", componentTexture.Read);
        fluidSimulationCompute.SetTexture(0, "inVelocityTexture", velocityTexture.Read);
        fluidSimulationCompute.SetTexture(0, "outComponentTexture", componentTexture.Write);
        fluidSimulationCompute.SetTexture(0, "outVelocityTexture", velocityTexture.Write);
        fluidSimulationCompute.SetTexture(0, "colliderTexture", (Collider == null)?Texture2D.blackTexture:Collider);

        fluidSimulationCompute.Dispatch(0, simulationSizeX / (int)ThreadGroupSizeX, simulationSizeY / (int)ThreadGroupSizeY, 1);

        velocityTexture.Swap();
        componentTexture.Swap();

        // Divergence

        fluidSimulationCompute.SetFloat("injectedDivergence", injectedDivergence);
        fluidSimulationCompute.SetVector("textureSize", textureSize);
        fluidSimulationCompute.SetTexture(1, "inVelocityTexture", velocityTexture.Read);
        fluidSimulationCompute.SetTexture(1, "outDivergenceTexture", divergenceTexture);
        fluidSimulationCompute.SetTexture(1, "outPressureTexture", pressureTexture.Write);

        fluidSimulationCompute.Dispatch(1, simulationSizeX / (int)ThreadGroupSizeX, simulationSizeY / (int)ThreadGroupSizeY, 1);
        pressureTexture.Swap();

        // Jacobi
        for(int i = 0; i < JacobiIterations; i++)
        {
            fluidSimulationCompute.SetTexture(2, "inPressureTexture", pressureTexture.Read);
            fluidSimulationCompute.SetTexture(2, "outPressureTexture", pressureTexture.Write);
            fluidSimulationCompute.SetTexture(2, "inDivergenceTexture", divergenceTexture);

            fluidSimulationCompute.Dispatch(2, simulationSizeX / (int)ThreadGroupSizeX, simulationSizeY / (int)ThreadGroupSizeY, 1);
            pressureTexture.Swap();
        }

        // Projection
        fluidSimulationCompute.SetTexture(3, "inPressureTexture", pressureTexture.Read);
        fluidSimulationCompute.SetTexture(3, "inVelocityTexture", velocityTexture.Read);
        fluidSimulationCompute.SetTexture(3, "outVelocityTexture", velocityTexture.Write);

        fluidSimulationCompute.Dispatch(3, simulationSizeX / (int)ThreadGroupSizeX, simulationSizeY / (int)ThreadGroupSizeY, 1);
        velocityTexture.Swap();

        // Vorticity

        fluidSimulationCompute.SetTexture(4, "inVelocityTexture", velocityTexture.Read);
        fluidSimulationCompute.SetTexture(4, "outVorticityTexture", vorticityTexture);

        fluidSimulationCompute.Dispatch(4, simulationSizeX / (int)ThreadGroupSizeX, simulationSizeY / (int)ThreadGroupSizeY, 1);

        fluidSimulationCompute.SetTexture(5, "inComponentTexture", componentTexture.Read);
        fluidSimulationCompute.SetTexture(5, "inVelocityTexture", velocityTexture.Read);
        fluidSimulationCompute.SetTexture(5, "outVelocityTexture", velocityTexture.Write);
        fluidSimulationCompute.SetTexture(5, "inVorticityTexture", vorticityTexture);
        fluidSimulationCompute.SetFloat("vorticityIntensity", VorticityIntensity * VorticityIntensity);
        fluidSimulationCompute.SetFloat("vorticityAttenuationByDensity", VorticityAttenuationByDensity);
        fluidSimulationCompute.SetFloat("vorticityAttenuationByVelocity", VorticityAttenuationByVelocity);       


        fluidSimulationCompute.Dispatch(5, simulationSizeX / (int)ThreadGroupSizeX, simulationSizeY / (int)ThreadGroupSizeY, 1);
        velocityTexture.Swap();

        // Rendering
        meshMaterial.SetTexture("_VelocityTexture", velocityTexture.Read);
        meshMaterial.SetTexture("_SmokeTexture", componentTexture.Read);
        meshMaterial.SetTexture("_DivergenceTexture", divergenceTexture);
        meshMaterial.SetTexture("_PressureTexture", pressureTexture.Read);
        meshMaterial.SetTexture("_VorticityTexture", vorticityTexture);
        meshMaterial.SetTexture("_ColliderTexture", (Collider == null || !UseColliderTexture) ? Texture2D.blackTexture : Collider);

        Shader.SetGlobalTexture("_VelocityTexture", velocityTexture.Read);
        Shader.SetGlobalTexture("_SmokeTexture", componentTexture.Read);
        Shader.SetGlobalVector("_MinSimulationBBox", meshRenderer.bounds.min);
        Shader.SetGlobalVector("_MaxSimulationBBox", meshRenderer.bounds.max);
    }
    #endregion
}
