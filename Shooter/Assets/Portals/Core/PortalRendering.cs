using UnityEngine;
using UnityEngine.Rendering;

public class PortalRendering : MonoBehaviour {

    Portal[] portals;

    void Awake () {
        portals = FindObjectsOfType<Portal> ();

    }
    private void OnEnable()
    {
        RenderPipelineManager.beginCameraRendering += OnBeginCameraRender;
    }

    void OnBeginCameraRender(ScriptableRenderContext context, Camera camera)
    {
        if (camera != Camera.main || !Application.isPlaying) return;
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

    void OnBeginFrameRendering()
    {
        //add your code here
    }

    void OnEndCameraRendering()
    {
    }
    void OnPreCull()
    {

    }
}