using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StarterAssets;

public class Hitscan : MonoBehaviour
{
    public GameObject hitPrefab;
    public LayerMask layerMask;
    public Transform hitscanOrigin;
    public float distance;

    private void Start()
    {
        if (hitscanOrigin == null) hitscanOrigin = transform;
    }

    //private void Update()
    //{
    //    if(TryGetComponent(out StarterAssetsInputs inputs))
    //    {
    //        if(inputs.shootHeld)
    //        {
    //            Shoot();
    //        }
    //    }
    //}

    public void Shoot()
    {
        if (Physics.Raycast(hitscanOrigin.position, hitscanOrigin.forward, out RaycastHit hit, distance, layerMask))
        {
            if (hitPrefab != null)
            {
                Instantiate(hitPrefab, hit.point, Quaternion.Euler(hit.normal));
            }
        }
    }
}
