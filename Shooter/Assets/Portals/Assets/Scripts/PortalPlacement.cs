using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PortalPlacement : MonoBehaviour
{
    [SerializeField]
    private PortalPair portals;

    [SerializeField]
    private LayerMask layerMask;

    [SerializeField]
    private Crosshair crosshair;

    [SerializeField]
    private float distance = 250f;

    [SerializeField]
    private Transform placementPos;

    private void Start()
    {
        if (placementPos == null) placementPos = transform;
    }

    public void OnShoot(InputAction.CallbackContext value)
    {
        if(value.started)
        {
            SetPortalCollider(1);
            FirePortal(0, placementPos.position, placementPos.forward, distance);
        }
    }
    public void OnShootOne(InputAction.CallbackContext value)
    {
        if (value.started)
        {
            SetPortalCollider(0);
            FirePortal(1, placementPos.position, placementPos.forward, distance);
        }
    }

    void SetPortalCollider(int portalID)
    {
        portals.Portals[portalID].GetComponent<Collider>().enabled = true;
    }


    private void FirePortal(int portalID, Vector3 pos, Vector3 dir, float distance)
    {
        Physics.Raycast(pos, dir, out RaycastHit hit, distance, layerMask);

        if(hit.collider != null)
        {
            // If we shoot a portal, recursively fire through the portal.
            if (hit.collider.transform.CompareTag("Portal"))
            {
                
                if (!hit.collider.TryGetComponent<Portal>(out var inPortal))
                {
                    return;
                }

                var outPortal = inPortal.OtherPortal;

                // Update position of raycast origin with small offset.
                Vector3 relativePos = inPortal.transform.InverseTransformPoint(hit.point + dir);
                relativePos = Quaternion.Euler(0.0f, 180.0f, 0.0f) * relativePos;
                pos = outPortal.transform.TransformPoint(relativePos);

                // Update direction of raycast.
                Vector3 relativeDir = inPortal.transform.InverseTransformDirection(dir);
                relativeDir = Quaternion.Euler(0.0f, 180.0f, 0.0f) * relativeDir;
                dir = outPortal.transform.TransformDirection(relativeDir);

                distance -= hit.distance;

                FirePortal(portalID, pos, dir, distance);
                return;
            }

            // Orient the portal according to camera look direction and surface direction.
            var cameraRotation = Camera.main.transform.rotation;
            var portalRight = cameraRotation * Vector3.right;
            
            if(Mathf.Abs(portalRight.x) >= Mathf.Abs(portalRight.z))
            {
                portalRight = (portalRight.x >= 0) ? Vector3.right : -Vector3.right;
            }
            else
            {
                portalRight = (portalRight.z >= 0) ? Vector3.forward : -Vector3.forward;
            }
            
            var portalForward = -hit.normal;
            var portalUp = -Vector3.Cross(portalRight, portalForward);
            
            var portalRotation = Quaternion.LookRotation(portalForward, portalUp);

            //var portalRotation = Quaternion.LookRotation(Vector3.Project(Camera.main.transform.forward, hit.normal));
            
            // Attempt to place the portal.
            bool wasPlaced = portals.Portals[portalID].PlacePortal(hit.collider, hit.point, portalRotation);

            if(crosshair != null && wasPlaced)
            {
                crosshair.SetPortalPlaced(portalID, true);
            }
        }
    }
}
