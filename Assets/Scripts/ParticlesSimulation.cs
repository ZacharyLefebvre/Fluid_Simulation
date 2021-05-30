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
            MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
            propertyBlock.SetFloat("_Id", (float)i);
            propertyBlock.SetFloat("_Rotation", Random.value * 2.0f * Mathf.PI);
            propertyBlock.SetFloat("_ActiveParticlesCount", activeParticlesCount);
            nenupharArray[i].GetComponent<Renderer>().SetPropertyBlock(propertyBlock);
            nenupharArray[i].SetActive(i < activeParticlesCount);
        }

        mainSimulationScript = GetComponent<FluidSimulation>();
        particleTexture = new SwappableRenderTexture(simulationSizeX, simulationSizeY, RenderTextureFormat.RGHalf, TextureWrapMode.Clamp, FilterMode.Point);

        particlesCompute.SetInt("seed", (int)(Random.value * 26852.41684));

        ComputeBuffer randomBuffer = new ComputeBuffer(simulationSizeX * simulationSizeY, sizeof(float) * 2);
        Vector2[] randomData = new Vector2[simulationSizeX * simulationSizeY];
        for (int i = 0; i < randomData.Length; i++)
        {
            //randomData[i] = new Vector2((float)(i % 64) / 64f, Mathf.Floor(((float)i / 64f)) / 64f);
            randomData[i] = new Vector2(Random.value, Random.value);
        }
        randomBuffer.SetData(randomData);

        particlesCompute.SetInts("textureSize", new int[] { (int)textureSize.x, (int)textureSize.y });
        particlesCompute.SetBuffer(1, "randomBuffer", randomBuffer);
        particlesCompute.SetTexture(1, "particleTextureWrite", particleTexture.Write);
        particlesCompute.Dispatch(1, Mathf.CeilToInt((float)simulationSizeX / (float)ThreadGroupSizeX), Mathf.CeilToInt((float)simulationSizeY / (float)ThreadGroupSizeY), 1);
        particleTexture.Swap();
        randomBuffer.Release();
    }

    private void Simulate()
    {
        particlesCompute.SetFloat("deltatime", Time.deltaTime);
        particlesCompute.SetInts("textureSize", new int[] { (int)textureSize.x, (int)textureSize.y });

        // Move Particles Kernel
        particlesCompute.SetTexture(0, "particleTextureRead", particleTexture.Read);
        particlesCompute.SetTexture(0, "particleTextureWrite", particleTexture.Write);
        particlesCompute.SetTexture(0, "velocityTexture", mainSimulationScript.velocityTexture.Read);
        particlesCompute.SetTexture(0, "colliderTexture", colliderTexture);
        
        particlesCompute.Dispatch(0, Mathf.CeilToInt((float)simulationSizeX / (float)ThreadGroupSizeX), Mathf.CeilToInt((float)simulationSizeY / (float)ThreadGroupSizeY), 1);
        particleTexture.Swap();

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
