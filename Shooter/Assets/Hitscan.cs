using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StarterAssets;
using DG.Tweening;
public class Hitscan : MonoBehaviour
{
    [Tooltip("Whether or not holding the button down fires the gun.")] public bool buttonHeld;
    public GameObject hitPrefab, missPrefab;
    public LayerMask layerMask;
    public Transform hitscanOrigin, gunObject;
    public float recoilDistance = 0.2f;
    public float distance;
    [Tooltip("Time inbetween shots.")] public float firingTime;
    public float damage;
    float timeSinceLastFire = Mathf.Infinity;
    StarterAssetsInputs inputs;

    private void Start()
    {
        if (hitscanOrigin == null) hitscanOrigin = transform;
        TryGetComponent(out inputs);
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
        if(gunObject != null) gunObject.DOPunchPosition(Vector3.back * recoilDistance, firingTime);
        if (Physics.Raycast(hitscanOrigin.position, hitscanOrigin.forward, out RaycastHit hit, distance, layerMask))
        {
            if(hit.transform.TryGetComponent(out Health health))
            {
                if (hitPrefab != null)
                {
                    Instantiate(hitPrefab, hit.point, Quaternion.Euler(hit.normal));
                    health.TakeDamage(Mathf.Max(damage, 1, damage), transform);
                }
            }
            else
            {
                if(missPrefab != null)
                {
                    Instantiate(missPrefab, hit.point, Quaternion.Euler(hit.normal));
                }
            }
        }
    }
}
