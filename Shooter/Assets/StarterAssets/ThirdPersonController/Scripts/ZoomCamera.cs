using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using Cinemachine;
using StarterAssets;
using DG.Tweening;

[RequireComponent(typeof(StarterAssetsInputs))]
public class ZoomCamera : MonoBehaviour
{
    public CinemachineVirtualCamera zoomCamera;
    public Volume zoomVolume;
    StarterAssetsInputs inputs;
    float BlendTime { get { return FindObjectOfType<CinemachineBrain>().m_DefaultBlend.m_Time; } }
    public bool zoomedIn { get { return zoomCamera != null && inputs.zoomIn; } }
    bool prevZoomIn;
    // Start is called before the first frame update
    void Start()
    {
        TryGetComponent(out inputs);
    }

    // Update is called once per frame
    void Update()
    {
        if (zoomCamera == null) return;
        zoomCamera.gameObject.SetActive(inputs.zoomIn);
        if(prevZoomIn != inputs.zoomIn)
        {
            DOVirtual.Float(prevZoomIn.GetHashCode(), inputs.zoomIn.GetHashCode(), BlendTime, ZoomVolumeWeight);
        }
        prevZoomIn = inputs.zoomIn;
        
    }

    void ZoomVolumeWeight(float weight)
    {
        if(zoomVolume != null)
        {
            zoomVolume.weight = weight;
        }
    }
}
