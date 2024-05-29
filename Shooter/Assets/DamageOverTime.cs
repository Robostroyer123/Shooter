using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DamageOverTime : MonoBehaviour
{
    public float damagePerSecond;
    Health health;
    // Start is called before the first frame update
    void Start()
    {
        TryGetComponent(out health);
    }

    // Update is called once per frame
    void Update()
    {
        if(health != null)
        health.TakeDamage(damagePerSecond * Time.deltaTime, transform);
        print("DPS");
    }
}
