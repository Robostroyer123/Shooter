using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Animations.Rigging;

public class EnemyNav : MonoBehaviour
{
    public float sightRange, stopRange;
    public float attackRange;
    
    [Space]
    public float walkPointRange = 5;
    public float walkPointStop = 1;
    [Space]
    public float attackCooldown = 1; 
    public float suspicionTime = 2;
    [Space]
    public Transform headAimFollow;
    public MultiAimConstraint headAimRig;

    public Transform gunSet;

    float timeSinceLastAttack, timeSinceLastSeen;

    bool walkPointSet;
    Vector3 walkPoint;

    Hitscan hitscan;
    NavMeshAgent agent;
    Health health;
    Animator animator;
    Transform CameraRoot { get { return GameObject.FindWithTag("CinemachineTarget").transform; } }
    Transform Player { get { return GameObject.FindWithTag("Player").transform; } }
    Vector3 PlayerCentre { get { return Player.TryGetComponent(out Collider col) ? col.bounds.center : Player.position; } }
    Vector3 VectorToPlayer { get { return Player.transform.position - transform.position; } }
    float DistanceToPlayer { get { return Vector3.Distance(transform.position, Player.transform.position); } }
    bool WithinRange(float range) { return DistanceToPlayer < range; }
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
        animator = GetComponentInChildren<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Player == null || (health != null && health.IsDead)) return;
        timeSinceLastAttack += Time.deltaTime;
        timeSinceLastSeen += Time.deltaTime;
        if(animator != null) { animator.SetFloat("Speed", agent.velocity.magnitude); }
        //if(gunSet != null)
        //{
        //    gunSet.LookAt(PlayerCentre);
        //}
        if (WithinRange(sightRange)) _ = timeSinceLastSeen = 0;
        if (!WithinRange(sightRange) && !WithinRange(attackRange) && timeSinceLastSeen > suspicionTime) { Patrol(); }
        if (!WithinRange(sightRange) && !WithinRange(attackRange) && timeSinceLastSeen <= suspicionTime) { Suspect(); }
        if (WithinRange(sightRange) && !WithinRange(attackRange)) { Chase(); }
        if (WithinRange(sightRange) && WithinRange(attackRange)) { Attack(); }
    }
    void Patrol()
    {
        if (!walkPointSet) { SearchWalkPoint(); }
        else { agent.SetDestination(walkPoint); }

        if (headAimRig != null)
        {
            headAimRig.weight = 0;
        }
        if (Vector3.Distance(transform.position, walkPoint) < walkPointStop)
        {
            walkPointSet = false;
        }
    }
    void Suspect()
    {
        agent.SetDestination(transform.position);
    }
    void SearchWalkPoint()
    {
        Vector3 randomPoint = transform.position + Random.insideUnitSphere * walkPointRange;
        if (NavMesh.SamplePosition(randomPoint, out NavMeshHit hit, 1.0f, NavMesh.AllAreas))
        {
            walkPoint = hit.position;
            walkPointSet = true;
        }
    }
    void Chase()
    {
        agent.SetDestination(Player.position);
        if(headAimFollow != null && CameraRoot != null)
        {
            headAimFollow.position = CameraRoot.position;
        }
        if(headAimRig != null)
        {
            headAimRig.weight = 1;
        }
    }
    void Attack()
    {
        transform.LookAt(Player);
        transform.rotation = Quaternion.Euler(Vector3.up * transform.eulerAngles.y);
        gunSet.transform.LookAt(PlayerCentre);
        if(timeSinceLastAttack > attackCooldown)
        {
            agent.SetDestination(transform.position);
            hitscan.Shoot();
            timeSinceLastAttack = 0;
        }
    }
    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, sightRange);

        Gizmos.color = Color.magenta;
        Gizmos.DrawWireSphere(transform.position, walkPointRange);

        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, attackRange);
    }
}
