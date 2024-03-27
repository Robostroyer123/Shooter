using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StarterAssets;

public class Hitscan : MonoBehaviour
{
    [Tooltip("Whether or not holding the button down fires the gun.")] public bool buttonHeld;
    public GameObject hitPrefab, missPrefab;
    public LayerMask layerMask;
    public Transform hitscanOrigin;
    public float distance;
    [Tooltip("Time inbetween shots.")] public float firingTime;
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
        print("Hitscan Shoot");
        timeSinceLastFire = 0;
        if (Physics.Raycast(hitscanOrigin.position, hitscanOrigin.forward, out RaycastHit hit, distance, layerMask))
        {
            if(hit.transform.TryGetComponent(out Health health))
            {
                if (hitPrefab != null)
                {
                    Instantiate(hitPrefab, hit.point, Quaternion.Euler(hit.normal));
                    health.TakeDamage(1, transform);
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
