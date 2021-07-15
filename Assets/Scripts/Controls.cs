using UnityEngine;
using UnityEngine.SceneManagement;

public class Controls : MonoBehaviour
{
    [SerializeField] private FluidSimulation fluidSimulation;
    [SerializeField] private ParticlesSimulation particlesSimulation;
    [SerializeField] private WaterRippleSimulation waterSimulation;
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            //SceneManager.LoadScene(0);

            fluidSimulation.OnRestart();
            particlesSimulation.OnRestart();
            waterSimulation.OnRestart();
        }
        
        if (Input.GetKeyDown(KeyCode.Escape))
        {
        #if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
        #else
            Application.Quit();
        #endif
        }
    }
}
