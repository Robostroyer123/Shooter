using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Slider))]
public class HealthBar : MonoBehaviour
{
    public Health healthObj;
    Slider healthSlider;
    private void Start()
    {
        healthSlider = GetComponent<Slider>();
    }
    // Update is called once per frame
    void Update()
    {
        if(healthObj == null) return;
        healthSlider.value = healthObj.healthFraction;
    }
}
