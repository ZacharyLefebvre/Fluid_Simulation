using UnityEngine;
using UnityEngine.UI;

public class ParticlesSimulation : MonoBehaviour
{
    [System.Serializable]
    public class NenufarData
    {
        public string name;
        public GameObject prefab;
        public int probaMin = 0;
        public int probaMax = 0;
    }

    public int MaxParticlesCount => (simulationSizeX * simulationSizeY);

    [SerializeField] private FluidSimulation mainSimulationScript = null;
    [SerializeField] private Transform nenupharSpawn = null;
    [SerializeField] private NenufarData[] nenufarPrefabs;
    // [SerializeField] private GameObject nenufarPrefab = null;
    [SerializeField] private Texture colliderTexture = null;
    [SerializeField] private Slider particleAmountSlider = null;
    [SerializeField] private NenupharAmount nenupharAmountScript = null;

    private SwappableRenderTexture particleTexture = null;
    private ComputeShader particlesCompute;
    private GameObject[] nenufarArray;

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
        GenerateNenuphars();
        Initialize();
    }

    private void Update()
    {
        Simulate();
    }

    private void OnDestroy()
    {
        Uninitialize();
    }

    #endregion

    #region Custom Functions

    private void GenerateNenuphars()
    {
        nenufarArray = new GameObject[MaxParticlesCount];
        for (int i = 0; i < MaxParticlesCount; i++)
        {
            int nenufarRoll = Random.Range(0, 101);
            int nenufarVisu = 0;

            for (int j = 0; j < nenufarPrefabs.Length; j++)
            {
                if (nenufarRoll >= nenufarPrefabs[j].probaMin && nenufarRoll <= nenufarPrefabs[j].probaMax)
                {
                    nenufarArray[i] = Instantiate(nenufarPrefabs[j].prefab, nenupharSpawn);
                    nenufarVisu = j;
                    break;
                }
                if (j == nenufarPrefabs.Length - 1)
                    Debug.Log($"no percentage matching this number : {nenufarRoll}");
            }

            // nenufarArray[i].transform.position += Vector3.up * (Random.value * 0.1f); // offset to avoid z-fighting
            MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
            propertyBlock.SetFloat("_Id", (float)i);
            propertyBlock.SetFloat("_Rotation", Random.value * 2.0f * Mathf.PI);
            propertyBlock.SetFloat("_ActiveParticlesCount", activeParticlesCount);
            propertyBlock.SetFloat("_NenufarIndex", (float)nenufarVisu);

            if (nenufarVisu == 2) // first lotus visu
            {
                // Color debug = new Vector4(Random.value, Random.value, Random.value, 1.0f);
                Color debug = Random.ColorHSV(0.0f, 1.0f, 0.6f, 1.0f, 0.6f, 1.0f, 1.0f, 1.0f);
                propertyBlock.SetColor("_LotusColor", debug);
            }

            nenufarArray[i].GetComponent<Renderer>().SetPropertyBlock(propertyBlock);

            nenufarArray[i].SetActive(i < activeParticlesCount);
        }
    }

    public void Initialize()
    {
        Camera.main.useOcclusionCulling = false;

        particleAmountSlider.onValueChanged.AddListener(UpdateParticleAmount);
        nenupharAmountScript.UpdateText(activeParticlesCount);

        
        particlesCompute = Resources.Load<ComputeShader>("ParticleCompute");
        particlesCompute.GetKernelThreadGroupSizes(0, out ThreadGroupSizeX, out ThreadGroupSizeY, out ThreadGroupSizeZ);
        textureSize = new Vector2(simulationSizeX, simulationSizeY);
        particleInvTextureSize = new Vector2(1.0f / (float)simulationSizeX, 1.0f / (float)simulationSizeY);

        activeParticlesCount = (int)particleAmountSlider.value;

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

    private void Uninitialize()
    {
        particleAmountSlider.onValueChanged.RemoveAllListeners();
        particleTexture.Release();
    }

    public void OnRestart()
    {
        Uninitialize();
        Initialize();

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
            nenufarArray[i].SetActive(i < activeParticlesCount);
        }
    }

    #endregion
}
