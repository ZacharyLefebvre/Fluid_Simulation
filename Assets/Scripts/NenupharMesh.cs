using UnityEditor;
using UnityEngine;

public class NenupharMesh : MonoBehaviour
{
    void Start()
    {
        Mesh mesh = GetComponent<MeshFilter>().sharedMesh;
        mesh.bounds = new Bounds(transform.position, new Vector3(100.0f, 100.0f, 100.0f));
        Mesh instance = (Mesh)Object.Instantiate(mesh);
        AssetDatabase.CreateAsset(instance, "Assets/Meshes/Lotus_Flower1.mesh");
    }
}
