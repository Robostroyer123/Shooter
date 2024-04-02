using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Portal : MonoBehaviour
{
    public Vector3 portalDirection = Vector3.back;
    public Transform reciever;
    public Transform Player;
    Vector3 PlayerPos { get { return Player.GetComponent<Collider>().bounds.center; } } 
    bool playerIsOverlapping = false;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void LateUpdate()
    {
        if (reciever == null) return;
        if(playerIsOverlapping)
        {
			Vector3 portalToPlayer = PlayerPos - transform.position;
			float dotProduct = Vector3.Dot(transform.TransformDirection(portalDirection.normalized), portalToPlayer);

			// If this is true: The player has moved across the portal
			if (dotProduct < 0f)
            {
                print(transform.name + ": " + reciever.name);
                // Teleport him!
                float rotationDiff = -Quaternion.Angle(transform.rotation, reciever.rotation);
				rotationDiff += 180;
				Player.Rotate(Vector3.up, rotationDiff);

				Vector3 positionOffset = Quaternion.Euler(0f, rotationDiff, 0f) * portalToPlayer;
                Player.position = positionOffset + reciever.position + Player.position - PlayerPos;

                playerIsOverlapping = false;
            }
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            playerIsOverlapping = true;
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            playerIsOverlapping = false;
        }
    }
}
