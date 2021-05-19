using UnityEngine;
using UnityEngine.UI;

public class ParticlesSimulation : MonoBehaviour
{
    public int MaxParticlesCount => (simulationSizeX * simulationSizeY);

    [SerializeField] private FluidSimulation mainSimulationScript = null;
    [SerializeField] private Transform nenupharSpawn = null;
    [SerializeField] private GameObject nenupharPrefab = null;
    [SerializeField] private Texture colliderTexture = null;
    [SerializeField] private Slider particleAmountSlider = null;

    private SwappableRenderTexture particleTexture = null;
    private ComputeShader particlesCompute;
    private GameObject[] nenupharArray;

    private Vector2 textureSize;
    private Vector2 particleInvTextureSize;
    private int activeParticlesCount = 100;
    private uint ThreadGroupSizeX;
    private uint ThreadGroupSizeY;
    private uint ThreadGroupSizeZ;

    public const int simulationSizeX = 64;
    public const int simulationSizeY = 64;

    #region Unity Functions
    private void Awake()
    {
        particleAmountSlider.onValueChanged.AddListener(UpdateParticleAmount);
        Initialize();
    }
    private void Update()
    {
        Simulate();
    }

    private void OnDestroy()
    {
        particleAmountSlider.onValueChanged.RemoveAllListeners();
        particleTexture.Release();
    }

    #endregion

    #region Custom Functions
    private void Initialize()
    {
        Camera.main.useOcclusionCulling = false;

        nenupharArray = new GameObject[MaxParticlesCount];
        particlesCompute = Resources.Load<ComputeShader>("ParticleCompute");
        particlesCompute.GetKernelThreadGroupSizes(0, out ThreadGroupSizeX, out ThreadGroupSizeY, out ThreadGroupSizeZ);
        textureSize = new Vector2(simulationSizeX, simulationSizeY);
        particleInvTextureSize = new Vector2(1.0f / (float)simulationSizeX, 1.0f / (float)simulationSizeY);

        activeParticlesCount = (int)particleAmountSlider.value;

        for (int i = 0; i < MaxParticlesCount; i++)
        {
            nenupharArray[i] = Instantiate(nenupharPrefab, nenupharSpawn);
            // nenupharArray[i].GetComponent<Renderer>().material.SetInt("_Id", i);
            MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
            propertyBlock.SetInt("_Id", i);
            nenupharArray[i].GetComponent<Renderer>().SetPropertyBlock(propertyBlock);

            nenupharArray[i].SetActive(i < activeParticlesCount);
        }

        mainSimulationScript = GetComponent<FluidSimulation>();
        particleTexture = new SwappableRenderTexture(simulationSizeX, simulationSizeY, RenderTextureFormat.RGHalf, TextureWrapMode.Clamp, FilterMode.Point);

        particlesCompute.SetInt("seed", (int)(Random.value * 26852.41684));

        particlesCompute.SetTexture(0, "colliderTexture", colliderTexture);
        particlesCompute.SetTexture(1, "particleTextureWrite", particleTexture.Write);
        particlesCompute.Dispatch(1, Mathf.CeilToInt((float)simulationSizeX / (float)ThreadGroupSizeX), Mathf.CeilToInt((float)simulationSizeY / (float)ThreadGroupSizeY), 1);
        particleTexture.Swap();
    }

    private void Simulate()
    {
        particlesCompute.SetFloat("deltatime", Time.deltaTime);
        particlesCompute.SetTexture(0, "particleTextureRead", particleTexture.Read);
        particlesCompute.SetTexture(0, "particleTextureWrite", particleTexture.Write);
        particlesCompute.SetTexture(0, "velocityTexture", mainSimulationScript.velocityTexture.Read);
        
        particlesCompute.Dispatch(0, Mathf.CeilToInt((float)simulationSizeX / (float)ThreadGroupSizeX), Mathf.CeilToInt((float)simulationSizeY / (float)ThreadGroupSizeY), 1);
        particleTexture.Swap();

        // Move Particles Kernel

        Shader.SetGlobalVector("particleInvTextureSize", particleInvTextureSize);
        Shader.SetGlobalTexture("particleTexture", particleTexture.Read);
    }

    public void UpdateParticleAmount(float value)
    {
        activeParticlesCount = (int)value;

        for (int i = 0; i < MaxParticlesCount; i++)
        {
            nenupharArray[i].SetActive(i < activeParticlesCount);
        }
    }

    #endregion

}
