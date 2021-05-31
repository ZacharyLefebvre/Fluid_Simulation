using UnityEngine;

public class WaterRippleSimulation : MonoBehaviour
{
    [SerializeField] private Texture collisionTexture = null;
    [SerializeField] private float injectionForce = 1;
    [SerializeField, Range(0.0f, 0.1f)] private float injectRadius = 0.01f;
    [SerializeField, Range(0.95f, 1.0f)] private float dampening = 0.95f;
    [SerializeField, Range(0, 5)] private int rippleSpeed = 1;
    [SerializeField] private LayerMask raycastLayerMask;

    private SwappableRenderTexture waterRippleTexture = null;
    private ComputeShader waterRippleCompute = null;
    private ParticlesSimulation particleSimulationScript = null;
    private FluidSimulation fluidSimulationScript = null;
    void Start()
    {
        Initialize();
    }

    void Update()
    {
        bool isInjecting = MouseManagement(out Vector2 uvHit);

        for (int i = 0; i < rippleSpeed; i++)
        {
            Shader.SetGlobalFloat("InjectionForce", injectionForce);
            Shader.SetGlobalTexture("WaterRipples", waterRippleTexture.Read);

            waterRippleCompute.SetVector("uvHit", uvHit);
            waterRippleCompute.SetFloat("injectionForce", injectionForce * (isInjecting ? 1.0f : 0.0f));
            waterRippleCompute.SetFloat("injectionRadius", injectRadius);
            waterRippleCompute.SetFloat("dampening", dampening);
            waterRippleCompute.SetVector("simulationSize", new Vector2(fluidSimulationScript.simulationSizeX, fluidSimulationScript.simulationSizeY));

            waterRippleCompute.SetTexture(0, "waterRippleRead", waterRippleTexture.Read);
            waterRippleCompute.SetTexture(0, "waterRippleWrite", waterRippleTexture.Write);
            waterRippleCompute.SetTexture(0, "waterRippleCollision", collisionTexture);
            waterRippleCompute.Dispatch(0, Mathf.CeilToInt((float)fluidSimulationScript.simulationSizeX / (float)fluidSimulationScript.ThreadGroupSizeX), Mathf.CeilToInt((float)fluidSimulationScript.simulationSizeY / (float)fluidSimulationScript.ThreadGroupSizeY), 1);
            waterRippleTexture.Swap();
        }
    }

    private void Initialize()
    {
        waterRippleCompute = Resources.Load<ComputeShader>("WaterRipplesCompute");
        particleSimulationScript = GetComponent<ParticlesSimulation>();
        fluidSimulationScript = GetComponent<FluidSimulation>();
        waterRippleTexture = new SwappableRenderTexture(fluidSimulationScript.simulationSizeX, fluidSimulationScript.simulationSizeY, RenderTextureFormat.RHalf, TextureWrapMode.Clamp, FilterMode.Bilinear);
    }

    private bool MouseManagement(out Vector2 uvHit)
    {
        if ((Input.GetMouseButton(0) || Input.GetMouseButton(1)) && Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out RaycastHit hit, 1000, raycastLayerMask))
        {
            uvHit = hit.textureCoord;
            return true;
        }

        uvHit = Vector2.zero;
        return false;
    }

}
