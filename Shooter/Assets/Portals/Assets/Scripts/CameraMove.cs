using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(Rigidbody))]
public class CameraMove : MonoBehaviour
{
    private const float moveSpeed = 7.5f;
    private const float cameraSpeed = 3.0f;

    public Quaternion TargetRotation { private set; get; }
    
    private Vector3 moveVector = Vector3.zero;
    private float elevation = 0.0f;

    private new Rigidbody rigidbody;

    Vector3 move;
    Vector2 look;

    public void OnMove(InputAction.CallbackContext value)
    {
        move = value.ReadValue<Vector3>();   
    }

    public void OnLook(InputAction.CallbackContext value)
    {
        look = value.ReadValue<Vector2>();
    }
    private void Awake()
    {
        rigidbody = GetComponent<Rigidbody>();
        Cursor.lockState = CursorLockMode.Locked;

        TargetRotation = transform.rotation;
    }

    private void Update()
    {
        // Rotate the camera.
        var rotation = new Vector2(look.y, look.x);
        var targetEuler = TargetRotation.eulerAngles + (Vector3)rotation * cameraSpeed;
        if(targetEuler.x > 180.0f)
        {
            targetEuler.x -= 360.0f;
        }
        targetEuler.x = Mathf.Clamp(targetEuler.x, -75.0f, 75.0f);
        TargetRotation = Quaternion.Euler(targetEuler);

        transform.rotation = Quaternion.Slerp(transform.rotation, TargetRotation, 
            Time.deltaTime * 15.0f);

        // Move the camera.
        float x = move.x;
        float z = move.y;
        elevation = move.z;
        moveVector = new Vector3(x, elevation, z).normalized * moveSpeed;

    }

    private void FixedUpdate()
    {
        Vector3 newVelocity = transform.TransformDirection(moveVector);
        rigidbody.velocity = newVelocity;
    }

    public void ResetTargetRotation()
    {
        TargetRotation = Quaternion.LookRotation(transform.forward, Vector3.up);
    }
}
