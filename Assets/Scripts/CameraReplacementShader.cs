using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraReplacementShader : MonoBehaviour
{
    public Shader ReplacementShader;

    void OnEnable()
    {
        Camera camera = GetComponent<Camera>();
        camera.SetReplacementShader(ReplacementShader, "RenderType");
    }
}