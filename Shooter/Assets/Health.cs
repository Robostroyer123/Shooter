using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Health : MonoBehaviour
{
    public float maxHealth;
    float health;
    bool isDead;
    public bool IsDead { get { return isDead; } }
    public void SetHealth(float value)
    {
        health = Mathf.Clamp(value, 0, maxHealth);
    }

    public void ResetHealth()
    {
        SetHealth(maxHealth);
    }

    public void TakeDamage(float damage)
    {
        health = Mathf.Max(health - damage, 0);
        if(health <= 0 && !isDead)
        {
            isDead = true;
            Die();
        }
    }
    public void HealHealth(float value, bool resurrect = false)
    {
        if(resurrect && isDead)
        {
            health = Mathf.Min(value, maxHealth);
            isDead = false;
            Resurrect();
        }
        else if(!isDead)
        {
            health = Mathf.Min(health + value, maxHealth);
        }
    }

    void Die()
    {
        print("Die");
    }

    void Resurrect()
    {
        print("Resurrect");
    }
    // Start is called before the first frame update
    void Start()
    {
        ResetHealth();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
