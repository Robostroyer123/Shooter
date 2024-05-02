using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyNav : MonoBehaviour
{
    public float chaseRange;
    public float shootRange;
    NavMeshAgent agent;
    Transform Player { get { return GameObject.FindWithTag("Player").transform; } }
    // Start is called before the first frame update
    void Start()
    {
        TryGetComponent(out agent);
    }

    // Update is called once per frame
    void Update()
    {
        if (Player == null) return;
        if(Vector3.Distance(transform.position, Player.transform.position) < chaseRange)
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
    }
}
