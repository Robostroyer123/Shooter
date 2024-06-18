using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Settings : MonoBehaviour
{
    public float sensitivity;
    public Slider sensitivitySlider;
    public static Settings defaultSettings { get; private set; }
    public void UpdateSettings()
    {
        sensitivity = sensitivitySlider.value;
    }
    private void OnEnable()
    {
        defaultSettings = this;
    }
    // Start is called before the first frame update
    void Start()
    {
        DontDestroyOnLoad(this);
        UpdateSettings();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
