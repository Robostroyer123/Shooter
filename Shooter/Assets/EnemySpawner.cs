using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

[System.Serializable]
public class Spawn
{
    public GameObject prefab;
    public float weight;
}

public class EnemySpawner : MonoBehaviour
{
    public bool spawnOnTimer;
    public int initialSpawn = 1;
    public float spawnCooldown = 5;
    public int spawnCount = 1;
    public float minDistanceToPlayer = 4f, minDistanceToEnemies = 2f;
    [Space]
    public int fixedEnemyCount = 1;
    [Tooltip("How many enemies to kill before the number of enemies increase.")] public int enemyKillMilestone = 50;
    [Space]
    [Header("Objects to Spawn")]
    [NonReorderable]
    [SerializeField] Spawn[] spawns = default;

    [Header("Spawner Area")]
    [SerializeField] Vector2 levelBounds = Vector2.one;
    Transform player;
    ScoreKeeper scoreKeeper;
    public int spawnedCount { get { return transform.childCount; } }
    int enemyCount;
    IEnumerator Start()
    {
        enemyCount = fixedEnemyCount;
        player = GameObject.FindWithTag("Player").transform;
        scoreKeeper = FindFirstObjectByType<ScoreKeeper>();
        SpawnPrefabs(initialSpawn);
        while (true)
        {
            yield return new WaitForSeconds(spawnCooldown);
            SpawnPrefabs(spawnCount);
        }
    }

    void Update()
    {
        if(scoreKeeper != null)
        {
            enemyCount = fixedEnemyCount + Mathf.FloorToInt(scoreKeeper.KillNumber / enemyKillMilestone);
        }
        if (spawnedCount < enemyCount)
        {
            SpawnPrefab();
        }
    }


    void SpawnPrefabs(int num = 1)
    {
        for (int i = 0; i < num; i++)
        {
            SpawnPrefab();
        }
    }

    void SpawnPrefab()
    {
        Vector3 origin = new(Random.Range(-levelBounds.x, levelBounds.x), 0, Random.Range(-levelBounds.y, levelBounds.y));
        if (RandomPoint(origin + transform.position, 10, out Vector3 point) && Vector3.Distance(player.position, point) > minDistanceToPlayer)
        {
            //float level = 1 + ((1 + ((Time.time / 60) * 0.046f)) - 1) / 0.33f;
            //level = Mathf.Min(level, 1);

            Spawn spawn = GetRandomSpawn();
            
            if (spawn != null)
            {
                GameObject enemy = Instantiate(spawn.prefab, point, Quaternion.identity, transform);
                //Damageable damageable = enemy.TryGetComponent(out Damageable damageable1) ? damageable1 : enemy.GetComponentInChildren<Damageable>();
                ////damageable.TrueMaxHitPoints() = Mathf.RoundToInt(level);
                //BaseStats baseStats = enemy.TryGetComponent(out BaseStats baseStats1) ? baseStats1 : enemy.GetComponentInChildren<BaseStats>();
                //if (baseStats != null && player != null)
                //{
                //    baseStats.startingLevel = Mathf.Clamp(player.GetComponent<BaseStats>().GetLevel() - 2, 1, 100);
                //    baseStats.UpdateLevel();
                //}
                //damageable.ResetDamage();

            }
        }
    }

    bool RandomPoint(Vector3 center, float range, out Vector3 result)
    {
        for (int i = 0; i < 30; i++)
        {
            Vector3 randomPoint = center + Random.insideUnitSphere * 10;
            if (NavMesh.SamplePosition(randomPoint, out NavMeshHit hit, 1.0f, NavMesh.AllAreas))
            {
                result = hit.position;
                return true;
            }
        }
        result = Vector3.zero;
        return false;
    }

    Spawn GetRandomSpawn()
    {
        float sum = 0;
        foreach (Spawn spawn in spawns)
        {
            sum += spawn.weight;
        }
        float randomWeight;
        do
        {
            if (sum == 0)
                return null;
            randomWeight = Random.Range(0, sum);
        }
        while (randomWeight == sum);
        foreach (Spawn spawn in spawns)
        {
            if (randomWeight < spawn.weight)
                return spawn;
            randomWeight -= spawn.weight;
        }
        return null;
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawCube(transform.position - Vector3.up * transform.position.y, new Vector3(levelBounds.x * 2, 2, levelBounds.y * 2));

    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(GameObject.FindWithTag("Player").transform.position, minDistanceToPlayer);

    }
}
