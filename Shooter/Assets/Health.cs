using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Health : MonoBehaviour
{
    public float maxHealth;
    float health;
    bool isDead;
    TeamSetting Team { get { return GetComponent<TeamSetting>(); } }
    public bool IsDead { get { return isDead; } }
    public void SetHealth(float value)
    {
        health = Mathf.Clamp(value, 0, maxHealth);
    }

    public void ResetHealth()
    {
        SetHealth(maxHealth);
    }

    public void TakeDamage(float damage, Transform instigator = null)
    {
        if (OnSameTeam(instigator))
        {
            return;
        }
        health = Mathf.Max(health - damage, 0);
        print("Hit: " + transform.name);
        if (health <= 0 && !isDead)
        {
            isDead = true;
            Die(instigator);
        }
    }

    private bool OnSameTeam(Transform instigator)
    {
        return Team != null && instigator.TryGetComponent(out TeamSetting enemyTeam) && enemyTeam.Team == Team.Team;
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

    void Die(Transform instigator)
    {
        print("Die" + instigator);
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
