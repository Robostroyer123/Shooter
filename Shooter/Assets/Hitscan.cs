using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StarterAssets;
using DG.Tweening;
public class Hitscan : MonoBehaviour
{
    [Tooltip("Whether or not holding the button down fires the gun.")] public bool buttonHeld;
    public int burstNumber = 1;
    [Space]
    public GameObject hitPrefab, missPrefab;
    public LayerMask layerMask;
    public Transform hitscanOrigin, gunObject;
    public float recoilDistance = 0.2f, recoilAngle = 20;
    [Range(0,89)] public float angleVariance;
    [Range(0, 89)] public float zoomedAngleVariance;
    public float distance;
    [Tooltip("Time inbetween shots.")] public float firingTime;
    public float damage;
    float timeSinceLastFire = Mathf.Infinity;

    StarterAssetsInputs inputs;
    ZoomCamera zoomCamera;

    private void Start()
    {
        if (hitscanOrigin == null) hitscanOrigin = transform;
        TryGetComponent(out inputs);
        TryGetComponent(out zoomCamera);
    }

    private void Update()
    {
        timeSinceLastFire += Time.deltaTime;
        if (inputs != null)
        {
            if((inputs.shootValue.ReadValueAsButton() || inputs.shootHeld) && (buttonHeld || inputs.shootValue.action.triggered))
            {
                Shoot();
            }
        }
    }

    public void Shoot()
    {
        if (timeSinceLastFire < firingTime) return;
        timeSinceLastFire = 0;
        if (gunObject != null) 
        { 
            gunObject.DOPunchPosition(Vector3.back * recoilDistance, firingTime);
            gunObject.DOPunchRotation(Vector3.right * -recoilAngle, firingTime);
        }
        for(int i = 0; i < burstNumber; i++)
        {
            float variance = zoomCamera != null && zoomCamera.zoomedIn ? zoomedAngleVariance : angleVariance;
            if (Physics.Raycast(hitscanOrigin.position, hitscanOrigin.forward + (Vector3)Random.insideUnitCircle* Mathf.Tan(Mathf.Deg2Rad * variance), out RaycastHit hit, distance, layerMask))
            {
                if (hit.transform.TryGetComponent(out Health health))
                {
                    if (hitPrefab != null)
                    {
                        Instantiate(hitPrefab, hit.point, Quaternion.Euler(hit.normal));
                        health.TakeDamage(Mathf.Max(damage, 1, damage), transform);
                    }
                }
                else
                {
                    if (missPrefab != null)
                    {
                        Instantiate(missPrefab, hit.point, Quaternion.Euler(hit.normal));
                    }
                }
            }
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        DrawCone(angleVariance);

        Gizmos.color = Color.red;
        DrawCone(zoomedAngleVariance);

        void DrawCone(float varianceInAngles, bool addDiagonals = false)
        {
            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + Vector3.right * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * distance);
            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward - Vector3.right * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * distance);

            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + Vector3.up * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * distance);
            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward - Vector3.up * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * distance);

            if (!addDiagonals) return;
            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + new Vector3(1, 1, 0).normalized * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * distance);
            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + new Vector3(-1, 1, 0).normalized * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * distance);

            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + new Vector3(1, -1, 0).normalized * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * distance);
            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + new Vector3(-1, -1, 0).normalized * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * distance);
        }
    }
}
