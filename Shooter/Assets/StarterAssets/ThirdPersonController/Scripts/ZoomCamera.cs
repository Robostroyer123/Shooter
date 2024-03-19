using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using StarterAssets;

public class ZoomCamera : MonoBehaviour
{
    public CinemachineVirtualCamera zoomCamera;
    StarterAssetsInputs inputs;
    // Start is called before the first frame update
    void Start()
    {
        TryGetComponent(out inputs);
    }

    // Update is called once per frame
    void Update()
    {
        if (zoomCamera == null || inputs == null) return;
        zoomCamera.gameObject.SetActive(inputs.zoomIn);
    }
}
