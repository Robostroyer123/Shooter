using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StarterAssets;
using DG.Tweening;
public class Hitscan : MonoBehaviour
{
    [Tooltip("Whether or not holding the button down fires the gun.")] public bool buttonHeld;
    [Space]
    public int burstNumber = 1;
    public bool fixedBurstPattern;
    public bool flatBottomPattern;
    [Space]
    [Tooltip("Time inbetween shots.")] public float firingTime;
    public float damage;
    [Space]
    public ParticleSystem particle;
    public GameObject hitPrefab, missPrefab;
    public LayerMask layerMask;
    public Transform hitscanOrigin, gunObject;
    public float recoilDistance = 0.2f, recoilAngle = 20;
    [Range(0,89)] public float angleVariance;
    [Range(0, 89)] public float zoomedAngleVariance;
    public float distance = 100f;
    [Space]
    public bool distanceFalloff;
    public AnimationCurve damageDistanceFalloff = AnimationCurve.EaseInOut(0, 1.5f, 1, 0.5f);
    float timeSinceLastFire = Mathf.Infinity;

    RaycastHit hit;

    StarterAssetsInputs inputs;
    ZoomCamera zoomCamera;

    private void Start()
    {
        if (hitscanOrigin == null) hitscanOrigin = transform;
        TryGetComponent(out inputs);
        TryGetComponent(out zoomCamera);

        if(particle != null)
        {
            var emission = particle.emission;
            emission.SetBursts(new ParticleSystem.Burst[] { new ParticleSystem.Burst(0.0f, burstNumber) });
        }
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
            gunObject.DOPunchPosition(Vector3.back * recoilDistance, firingTime, 1);
            gunObject.DOPunchRotation(Vector3.right * -recoilAngle, firingTime, 1);
        }
        for(int i = 0; i < burstNumber; i++)
        {
            HitScan(i);
        }

        void HitScan(float i = 0)
        {
            //print(i);
            float variance = zoomCamera != null && zoomCamera.zoomedIn ? zoomedAngleVariance : angleVariance;
            float rayRotation = flatBottomPattern ? 180 / burstNumber : 0;
            if (fixedBurstPattern ? Physics.Raycast(hitscanOrigin.position, hitscanOrigin.forward + Quaternion.AngleAxis((i / burstNumber) * 360 + rayRotation, hitscanOrigin.forward) * Vector3.up * Mathf.Tan(Mathf.Deg2Rad * variance), out hit, distance, layerMask)
                : Physics.Raycast(hitscanOrigin.position, hitscanOrigin.forward + (Vector3)Random.insideUnitCircle * Mathf.Tan(Mathf.Deg2Rad * variance), out hit, distance, layerMask))
            {
                if(particle != null)
                {
                    particle.Play();
                }
                if (hit.transform.TryGetComponent(out Health health))
                {
                    if (hitPrefab != null)
                    {
                        float damageDistModifier = !distanceFalloff ? 1 : damageDistanceFalloff.Evaluate(hit.distance / distance);
                        Instantiate(hitPrefab, hit.point, Quaternion.Euler(hit.normal));
                        health.TakeDamage(Mathf.Max(damage, 1, damage) * damageDistModifier, transform);
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
        if(hitscanOrigin != null) DrawCone(angleVariance);

        Gizmos.color = Color.red;
        if (hitscanOrigin != null) DrawCone(zoomedAngleVariance);

        void DrawCone(float varianceInAngles, bool addDiagonals = false)
        {
            if(!fixedBurstPattern)
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
            else
            {
                for (int i = 0; i < burstNumber; i++)
                {
                    float rayRotation = flatBottomPattern ? 180 / burstNumber : 0;
                    DrawRay(i, varianceInAngles, rayRotation);
                }
            }
        }

        void DrawRay(float i, float varianceInAngles, float rayRotation = 0)
        { 
            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + Quaternion.AngleAxis(i / burstNumber * 360 + rayRotation, hitscanOrigin.forward) * Vector3.up * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * distance); 
        }
    }
}
