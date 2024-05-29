using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthKit : MonoBehaviour
{
    public float healAmount = 10;
    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Player"))
        {
            if(other.TryGetComponent(out Health health))
            {
                health.HealHealth(healAmount);
                Destroy(gameObject);
            }
        }
    }
}
