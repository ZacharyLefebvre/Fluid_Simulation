using TMPro;
using UnityEngine;

public class NenupharAmount : MonoBehaviour
{
    private TextMeshProUGUI textComponent;

    private void Awake()
    {
        textComponent = GetComponent<TextMeshProUGUI>();
    }

    public void UpdateText(float nenupharAmount)
    {
        textComponent.text = $"Nenuphar amount : {nenupharAmount}";
    }
}
