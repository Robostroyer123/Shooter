using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
public class PortalRendererFeature : ScriptableRendererFeature
{
    Portal[] portals { get { return FindObjectsByType<Portal>(FindObjectsSortMode.None); } }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
    }
    void OnBeginCameraRender()
    {
        for (int i = 0; i < portals.Length; i++)
        {
            portals[i].PrePortalRender();
        }

        for (int i = 0; i < portals.Length; i++)
        {
            portals[i].Render();
        }

        for (int i = 0; i < portals.Length; i++)
        {
            portals[i].PostPortalRender();
        }
    }
    public override void Create()
    {
        //OnBeginCameraRender();
        
    }
}
