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
    public ParticleSystem particle;
    public GameObject hitPrefab, missPrefab;
    public LayerMask layerMask;
    public Transform hitscanOrigin, gunObject;
    public float recoilDistance = 0.2f, recoilAngle = 20;
    [Range(0,89)] public float angleVariance;
    [Range(0, 89)] public float zoomedAngleVariance;
    public float standardDistance = 100f;
    public AnimationCurve damageDistanceFalloff = AnimationCurve.EaseInOut(0, 1.5f, 1, 0.5f);
    [Tooltip("Time inbetween shots.")] public float firingTime;
    public float damage;
    float timeSinceLastFire = Mathf.Infinity;

    RaycastHit hit;
    ParticleSystem.Particle[] m_Particles;

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
            gunObject.DOPunchPosition(Vector3.back * recoilDistance, firingTime, 1);
            gunObject.DOPunchRotation(Vector3.right * -recoilAngle, firingTime, 1);
        }
        for(int i = 0; i < burstNumber; i++)
        {
            HitScan(i, i);
        }

        void HitScan(float f = 0, int i = 0)
        {
            //print(i);
            float variance = zoomCamera != null && zoomCamera.zoomedIn ? zoomedAngleVariance : angleVariance;
            float rayRotation = flatBottomPattern ? 180 / burstNumber : 0;
            if (fixedBurstPattern ? Physics.Raycast(hitscanOrigin.position, hitscanOrigin.forward + Quaternion.AngleAxis((f / burstNumber) * 360 + rayRotation, hitscanOrigin.forward) * Vector3.up * Mathf.Tan(Mathf.Deg2Rad * variance), out hit, standardDistance, layerMask)
                : Physics.Raycast(hitscanOrigin.position, hitscanOrigin.forward + (Vector3)Random.insideUnitCircle * Mathf.Tan(Mathf.Deg2Rad * variance), out hit, standardDistance, layerMask))
            {
                if(particle != null)
                {
                    if (m_Particles == null || m_Particles.Length < particle.main.maxParticles)
                        m_Particles = new ParticleSystem.Particle[particle.main.maxParticles];

                    particle.Emit(burstNumber);// GetParticles is allocation free because we reuse the m_Particles buffer between updates

                    m_Particles[i].rotation3D = Quaternion.LookRotation(hit.point - hitscanOrigin.position) * Vector3.forward;

                    // Apply the particle changes to the Particle System
                    particle.SetParticles(m_Particles, burstNumber);
                }
                if (hit.transform.TryGetComponent(out Health health))
                {
                    if (hitPrefab != null)
                    {
                        float damageDistModifier = damageDistanceFalloff.Evaluate(hit.distance / standardDistance);
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
                Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + Vector3.right * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * standardDistance);
                Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward - Vector3.right * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * standardDistance);

                Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + Vector3.up * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * standardDistance);
                Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward - Vector3.up * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * standardDistance);

                if (!addDiagonals) return;
                Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + new Vector3(1, 1, 0).normalized * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * standardDistance);
                Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + new Vector3(-1, 1, 0).normalized * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * standardDistance);

                Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + new Vector3(1, -1, 0).normalized * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * standardDistance);
                Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + new Vector3(-1, -1, 0).normalized * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * standardDistance);
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
            Gizmos.DrawRay(hitscanOrigin.position, (hitscanOrigin.forward + Quaternion.AngleAxis(i / burstNumber * 360 + rayRotation, hitscanOrigin.forward) * Vector3.up * Mathf.Tan(Mathf.Deg2Rad * varianceInAngles)) * standardDistance); 
        }
    }
}
