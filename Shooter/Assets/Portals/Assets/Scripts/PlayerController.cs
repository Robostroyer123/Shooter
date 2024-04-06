using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : PortalableObject
{
    private CameraMove cameraMove;

    protected override void Start()
    {
        base.Start();

        cameraMove = GetComponent<CameraMove>();
    }

    public override void Warp()
    {
        base.Warp();
        cameraMove.ResetTargetRotation();
    }
}
