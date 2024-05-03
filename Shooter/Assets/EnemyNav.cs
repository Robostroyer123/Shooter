using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyNav : MonoBehaviour
{
    public float chaseRange, stopRange;
    public float shootRange;

    public Transform gunSet;

    Hitscan hitscan;
    NavMeshAgent agent;
    Health health;
    Transform Player { get { return GameObject.FindWithTag("Player").transform; } }
    Vector3 PlayerCentre { get { return Player.TryGetComponent(out Collider col) ? col.bounds.center : Player.position; } }
    float DistanceToPlayer { get { return Vector3.Distance(transform.position, Player.transform.position); } }
    // Start is called before the first frame update
    void Start()
    {
        TryGetComponent(out agent);
        TryGetComponent(out hitscan);
        TryGetComponent(out health);
        if(hitscan != null)
        {
            hitscan.SetTimeSinceLastFire(0);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Player == null || (health != null && health.IsDead)) return;
        if(gunSet != null)
        {
            gunSet.LookAt(PlayerCentre);
        }
        if(hitscan != null)
        {
            if(DistanceToPlayer < shootRange)
            {
                hitscan.Shoot();
            }
        }
        if(DistanceToPlayer < chaseRange && DistanceToPlayer > stopRange)
        {
            agent.isStopped = false;
            agent.SetDestination(Player.transform.position);
        }
        else
        {
            agent.isStopped = true;
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, chaseRange);

        Gizmos.color = Color.black;
        Gizmos.DrawWireSphere(transform.position, shootRange);

        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, stopRange);
    }
}
