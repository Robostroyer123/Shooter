using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleObjectKill : MonoBehaviour
{
    ParticleSystem particle;
    private void Start()
    {
        if(TryGetComponent(out particle))
        {
            Destroy(gameObject, particle.main.duration);
        }
    }
}
