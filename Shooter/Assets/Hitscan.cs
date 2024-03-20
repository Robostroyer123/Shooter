using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StarterAssets;

public class Hitscan : MonoBehaviour
{
    public LayerMask layerMask;
    public Transform hitscanOrigin;
    public float distance;

    private void Start()
    {
        if (hitscanOrigin == null) hitscanOrigin = transform;
    }

    private void Update()
    {
        if(TryGetComponent(out StarterAssetsInputs inputs))
        {
            if(inputs.shootHeld)
            {
                if(Physics.Raycast(hitscanOrigin.position, hitscanOrigin.forward, out RaycastHit hit, distance, layerMask))
                {
                    print(hit.transform.name);
                }
            }
        }
    }
}
