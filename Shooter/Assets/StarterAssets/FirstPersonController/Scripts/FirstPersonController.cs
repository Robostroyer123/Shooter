﻿using UnityEngine;
using System.Collections;

#if ENABLE_INPUT_SYSTEM
using UnityEngine.InputSystem;
#endif
using DG.Tweening;

namespace StarterAssets
{
	[RequireComponent(typeof(CharacterController))]
#if ENABLE_INPUT_SYSTEM
	[RequireComponent(typeof(PlayerInput))]
#endif
	public class FirstPersonController : MonoBehaviour
	{
		[Header("Player")]
		[Tooltip("Move speed of the character in m/s")]
		public float MoveSpeed = 4.0f;
		[Tooltip("Sprint speed of the character in m/s")]
		public float SprintSpeed = 6.0f;
		[Tooltip("Rotation speed of the character")]
		public float RotationSpeed = 1.0f;
		[Tooltip("Acceleration and deceleration")]
		public float SpeedChangeRate = 10.0f;

		[Space(10)]
		[Tooltip("The height the player can jump")]
		public float JumpHeight = 1.2f;
		[Tooltip("The number of midair jumps the player can do.")]
		public int MaxNumberOfMidairJumps = 1;
        [Tooltip("The character uses its own gravity value. The engine default is -9.81f")]
		public float Gravity = -15.0f;
        [Tooltip("The delay between leaving a platform and the ability to jump is disabled.")]
        public float CoyoteTime = 0.2f;

		[Space(10)]
		[Tooltip("Whether or not dashing requires moving the input stick.")]
		public bool dashMoveInputRequired;
        public bool dashInInputDirection;
		public float dashSpeed = 20f;
		public float dashDuration = 1;

        [Space(10)]
		[Tooltip("Time required to pass before being able to jump again. Set to 0f to instantly jump again")]
		public float JumpTimeout = 0.1f;
		[Tooltip("Time required to pass before entering the fall state. Useful for walking down stairs")]
		public float FallTimeout = 0.15f;

		[Header("Player Grounded")]
		[Tooltip("If the character is grounded or not. Not part of the CharacterController built in grounded check")]
		public bool Grounded = true;
		public bool OnRightWall, OnLeftWall;
		public bool Climb;
		[Tooltip("Useful for rough ground")]
		public float GroundedOffset = -0.14f;
		public Vector2 LeftWallOffset = Vector2.one * -0.14f, RightWallOffset = Vector2.one * 0.14f;
		public Vector3 ClimbOffset;
		[Tooltip("The radius of the grounded check. Should match the radius of the CharacterController")]
		public float GroundedRadius = 0.5f;
		[Tooltip("What layers the character uses as ground")]
		public LayerMask GroundLayers;

		[Space(10)]
		public bool canWallRun, canClimb;
		public float wallRunTime;
		public float wallRunDutch = 15;
        public float wallRunEndVerticalVelocity = 15;
        public float climbSpeed = 8;
		[Range(0, 1)] public float climbHorizontalMovementFraction = .25f;

		[Header("Cinemachine")]
		[Tooltip("The follow target set in the Cinemachine Virtual Camera that the camera will follow")]
		public GameObject CinemachineCameraTarget;
		[Tooltip("How far in degrees can you move the camera up")]
		public float TopClamp = 90.0f;
		[Tooltip("How far in degrees can you move the camera down")]
		public float BottomClamp = -90.0f;

		public Vector3 PortalVelocity { get; set; }

		// cinemachine
		private float _cinemachineTargetPitch;

		// player
		private float _speed;
		private float _rotationVelocity;
		private float _verticalVelocity;
		private float _terminalVelocity = 53.0f;

		// timeout deltatime
		private float _jumpTimeoutDelta;
		private float _fallTimeoutDelta;

	
#if ENABLE_INPUT_SYSTEM
		private PlayerInput _playerInput;
#endif
		private CharacterController _controller;
		private StarterAssetsInputs _input;
		private GameObject _mainCamera;

		private Vector3 dashVelocity;

		private const float _threshold = 0.01f;

		private float _timeSinceLeftGround;

		private float _timeSinceLeftWallLeft, _timeSinceLeftWallRight;

		private float _timeSinceLeftClimb;

		private float _timeSinceWallRun;

		private int _numberOfMidairJumpsLeft;

        float wallRunVerticalVelocity;

        private bool _isDashing, _dashCancel;
		public bool HasMidairJumps { get { return _numberOfMidairJumpsLeft > 0; } }
        private bool IsCurrentDeviceMouse
		{
			get
			{
				#if ENABLE_INPUT_SYSTEM
				return _playerInput.currentControlScheme == "KeyboardMouse";
				#else
				return false;
				#endif
			}
		}
		// set sphere position, with offset
		private Vector3 GroundedSpherePosition { get { return new(transform.position.x, transform.position.y - GroundedOffset, transform.position.z); } }
		private Vector3 ClimbSpherePosition { get { return transform.position + transform.TransformVector(ClimbOffset); } }
		private Vector3 LeftWallSpherePosition { get { return new Vector3(transform.position.x, transform.position.y + LeftWallOffset.y, transform.position.z) + transform.right * LeftWallOffset.x; } }
		private Vector3 RightWallSpherePosition { get { return new Vector3(transform.position.x, transform.position.y + RightWallOffset.y, transform.position.z) + transform.right * RightWallOffset.x; } }
		private bool CollisionSphere(Vector3 position)
        {
			return Physics.CheckSphere(position, GroundedRadius, GroundLayers, QueryTriggerInteraction.Ignore);
		}
        private bool GroundedSphere
        {
            get
            {
				return CollisionSphere(GroundedSpherePosition);
            }
		}
		private bool LeftWallSphere
		{
			get
			{
				return CollisionSphere(LeftWallSpherePosition);
			}
		}
		private bool RightWallSphere
		{
			get
			{
				return CollisionSphere(RightWallSpherePosition);
			}
		}
		private bool ClimbSphere
        {
			get
            {
				return CollisionSphere(ClimbSpherePosition);
            }
        }
		public bool OnWalled
        {
			get
            {
				return LeftWallSphere || RightWallSphere;
            }
        }
		public bool WallCling { get { return (LeftWallSphere && _input.move.x < 0) || (RightWallSphere && _input.move.x > 0); } }
		private void Awake()
		{
			// get a reference to our main camera
			if (_mainCamera == null)
			{
				_mainCamera = GameObject.FindGameObjectWithTag("MainCamera");
			}
		}

		private void Start()
		{
			_controller = GetComponent<CharacterController>();
			_input = GetComponent<StarterAssetsInputs>();
#if ENABLE_INPUT_SYSTEM
			_playerInput = GetComponent<PlayerInput>();
#else
			Debug.LogError( "Starter Assets package is missing dependencies. Please use Tools/Starter Assets/Reinstall Dependencies to fix it");
#endif

			// reset our timeouts on start
			_jumpTimeoutDelta = JumpTimeout;
			_fallTimeoutDelta = FallTimeout;
		}

		private void Update()
		{
			JumpAndGravity();
			GroundedCheck();
			WallCheck();
			ClimbCheck();
			if (WallRun() || WallClimbMove) _numberOfMidairJumpsLeft = MaxNumberOfMidairJumps;
			Move();
			WallRunMovement();
			ClimbMovement();
		}

		private void LateUpdate()
		{
			CameraRotation();
		}
		void WallCheck()
        {
			LeftWallCheck();
			RightWallCheck();
		}
		private void GroundedCheck()
		{
			if(!GroundedSphere)
			{
				_timeSinceLeftGround += Time.deltaTime;
			}
			else
			{
				_timeSinceLeftGround = 0;
				_numberOfMidairJumpsLeft = MaxNumberOfMidairJumps;
			}
			Grounded = _timeSinceLeftGround < CoyoteTime;
		}
		private void LeftWallCheck()
		{
			if (!LeftWallSphere)
			{
				_timeSinceLeftWallLeft += Time.deltaTime;
			}
			else
			{
				_timeSinceLeftWallLeft = 0;
			}
			OnLeftWall = _timeSinceLeftWallLeft < CoyoteTime;
		}
		private void RightWallCheck()
		{
			if (!RightWallSphere)
			{
				_timeSinceLeftWallRight += Time.deltaTime;
			}
			else
			{
				_timeSinceLeftWallRight = 0;
			}
			OnRightWall = _timeSinceLeftWallRight < CoyoteTime;
		}

		private void ClimbCheck()
        {
			if(!ClimbSphere)
            {
				_timeSinceLeftClimb += Time.deltaTime;
            }
			else
            {
				_timeSinceLeftClimb = 0;
            }
			Climb = _timeSinceLeftClimb < CoyoteTime;
        }

		private void CameraRotation()
		{
			// if there is an input
			if (_input.look.sqrMagnitude >= _threshold)
			{
				//Don't multiply mouse input by Time.deltaTime
				float deltaTimeMultiplier = IsCurrentDeviceMouse ? 1.0f : Time.deltaTime;
				
				_cinemachineTargetPitch += _input.look.y * RotationSpeed * deltaTimeMultiplier;
				_rotationVelocity = _input.look.x * RotationSpeed * deltaTimeMultiplier;

				// clamp our pitch rotation
				_cinemachineTargetPitch = ClampAngle(_cinemachineTargetPitch, BottomClamp, TopClamp);

				// Update Cinemachine camera target pitch
				CinemachineCameraTarget.transform.localRotation = Quaternion.Euler(_cinemachineTargetPitch, 0.0f, 0.0f);

				// rotate the player left and right
				transform.Rotate(Vector3.up * _rotationVelocity);
			}
		}

		private void Move()
		{
			// set target speed based on move speed, sprint speed and if sprint is pressed
			float targetSpeed = _input.sprint ? SprintSpeed : MoveSpeed;

			// a simplistic acceleration and deceleration designed to be easy to remove, replace, or iterate upon

			// note: Vector2's == operator uses approximation so is not floating point error prone, and is cheaper than magnitude
			// if there is no input, set the target speed to 0
			if (_input.move == Vector2.zero) targetSpeed = 0.0f;

			// a reference to the players current horizontal velocity
			float currentHorizontalSpeed = new Vector3(_controller.velocity.x, 0.0f, _controller.velocity.z).magnitude;

			float speedOffset = 0.1f;
			float inputMagnitude = _input.analogMovement ? _input.move.magnitude : 1f;

			// accelerate or decelerate to target speed
			if (currentHorizontalSpeed < targetSpeed - speedOffset || currentHorizontalSpeed > targetSpeed + speedOffset)
			{
				// creates curved result rather than a linear one giving a more organic speed change
				// note T in Lerp is clamped, so we don't need to clamp our speed
				_speed = Mathf.Lerp(currentHorizontalSpeed, targetSpeed * inputMagnitude, Time.deltaTime * SpeedChangeRate);

				// round speed to 3 decimal places
				_speed = Mathf.Round(_speed * 1000f) / 1000f;
			}
			else
			{
				_speed = targetSpeed;
			}

			// normalise input direction
			Vector3 inputDirection = new Vector3(_input.move.x, 0.0f, _input.move.y).normalized;

			// note: Vector2's != operator uses approximation so is not floating point error prone, and is cheaper than magnitude
			// if there is a move input rotate player when the player is moving
			if (_input.move != Vector2.zero)
			{
				// move
				inputDirection = transform.right * _input.move.x + transform.forward * _input.move.y;
			}
            // move the player
            if (!_isDashing && !WallRun() && !WallClimbMove) _controller.Move(inputDirection.normalized * (_speed * Time.deltaTime) + new Vector3(0.0f, _verticalVelocity, 0.0f) * Time.deltaTime + dashVelocity * Time.deltaTime);
		}

		private void JumpAndGravity()
		{
			if (GroundedSphere)
			{
				// reset the fall timeout timer
				_fallTimeoutDelta = FallTimeout;

				// stop our velocity dropping infinitely when grounded
				if (_controller.isGrounded && _verticalVelocity < 0.0f)
				{
					_verticalVelocity = -2f;
				}

				// Jump
				//if (_input.jump && _jumpTimeoutDelta <= 0.0f)
				//{
				//	// the square root of H * -2 * G = how much velocity needed to reach desired height
				//	_verticalVelocity = Mathf.Sqrt(JumpHeight * -2f * Gravity);
				//}

				// jump timeout
				//if (_jumpTimeoutDelta >= 0.0f)
				//{
				//	_jumpTimeoutDelta -= Time.deltaTime;
				//}
			}
			//else
			//{
			//	// reset the jump timeout timer
			//	_jumpTimeoutDelta = JumpTimeout;
			//
			//	// fall timeout
			//	if (_fallTimeoutDelta >= 0.0f)
			//	{
			//		_fallTimeoutDelta -= Time.deltaTime;
			//	}
			//
			//	// if we are not grounded, do not jump
			//	_input.jump = false;
			//}
			// apply gravity over time if under terminal (multiply by delta time twice to linearly speed up over time)

			if (_verticalVelocity < _terminalVelocity)
			{
				_verticalVelocity += Gravity * Time.deltaTime;
			}
		}
		public bool WallRun()
		{
			return canWallRun && !Grounded && WallCling && !(OnRightWall && OnLeftWall) && !Physics.Raycast(ClimbSpherePosition - transform.forward * GroundedRadius, transform.forward, GroundedRadius * 2, GroundLayers, QueryTriggerInteraction.Ignore);
		}

		void WallRunMovement()
		{
			//float prevDutch = 0;
			//float desiredDutch = WallRun() ? wallRunDutch * _input.move.x : 0;
			//DOVirtual.Float(0, desiredDutch, 0.2f, Dutch);
			//Dutch(desiredDutch);
			if (!WallRun() || WallClimbMove)
            {
				//prevDutch = desiredDutch;
				_timeSinceWallRun = 0;
                return;
			}
			if (_timeSinceWallRun < wallRunTime)
			{
				_timeSinceWallRun += Time.deltaTime;
				_verticalVelocity = 0;
                wallRunVerticalVelocity = 0;
            }
			else
			{
				wallRunVerticalVelocity = wallRunEndVerticalVelocity;
			}

			Vector3 normal;
            RaycastHit hit;
            if (OnRightWall)
            {
                normal = Physics.Raycast(RightWallSpherePosition - transform.right * GroundedRadius, transform.right, out hit, GroundedRadius * 2 + RightWallOffset.x) ? hit.normal : -transform.right;
            }
            else if(OnLeftWall)
            {
                normal = Physics.Raycast(LeftWallSpherePosition + transform.right * GroundedRadius, -transform.right, out hit, GroundedRadius * 2 - LeftWallOffset.x) ? hit.normal : transform.right;
            }
			else
            {
				//Shouldn't happen but just in case
				return;
			}
            Vector3 wallRunDirection = Vector3.ProjectOnPlane(transform.forward, normal);
            _controller.Move(SprintSpeed * Time.deltaTime * wallRunDirection.normalized + Time.deltaTime * wallRunVerticalVelocity * Vector3.up);
			//prevDutch = desiredDutch;
		}
		public bool WallClimbMove
        {
            get
            {
				return canClimb && Climb && _input.move.y > 0;
            }
        }
		void ClimbMovement()
        {
			if (WallClimbMove && !WallRun())
			{
				_verticalVelocity = 0;
				Vector3 normal = Physics.Raycast(ClimbSpherePosition - transform.forward * GroundedRadius, transform.forward, out RaycastHit hit, GroundedRadius * 2, GroundLayers, QueryTriggerInteraction.Ignore) ? hit.normal : -transform.forward;
				Vector3 wallClimbDirection = Vector3.ProjectOnPlane(Vector3.up * _input.move.y + climbHorizontalMovementFraction * _input.move.x * transform.right, normal);
				_controller.Move(climbSpeed * Time.deltaTime * wallClimbDirection.normalized);
			}

        }
		void Dutch(float dutch)
        {
			Camera.main.GetComponent<Cinemachine.CinemachineBrain>().ActiveVirtualCamera.VirtualCameraGameObject.GetComponent<Cinemachine.CinemachineVirtualCamera>().m_Lens.Dutch = dutch;

		}

		public void InvertVerticalVelocity()
        {
			_verticalVelocity *= -1;
        }
        public void Jump()
        {
            // the square root of H * -2 * G = how much velocity needed to reach desired height
            _verticalVelocity = Mathf.Sqrt(JumpHeight * -2f * Gravity);
			if (!Grounded)
			{
				_numberOfMidairJumpsLeft--;
			}
        }

		public void Dash()
		{
			float startTime = Time.time;
			if (!Grounded)
			{
				_numberOfMidairJumpsLeft--;
			}
			StartCoroutine(DashSettings(startTime));
			StartCoroutine(DashMovement(startTime));
			StartCoroutine(DashCancel(startTime));
		}
		IEnumerator DashSettings(float startTime)
		{
			_isDashing = true;
			dashVelocity = DashDirection.normalized * dashSpeed;
            if (!_dashCancel)
			{
				while (Time.time < startTime + dashDuration)
				{
					yield return null;
                }
			}
			dashVelocity = Vector3.zero;
			_isDashing = false;
		}
		IEnumerator DashMovement(float startTime)
		{
			_verticalVelocity = 0;
			_controller.SimpleMove(Vector3.right * _controller.velocity.x + Vector3.forward * _controller.velocity.z);
			if (!_dashCancel)
			{
				while (Time.time < startTime + dashDuration)
				{
					if (Grounded && !_dashCancel)
					{
						_verticalVelocity = Gravity;
					}
					else
					{
						_verticalVelocity = 0;
					}
					_controller.Move(dashSpeed * Time.deltaTime * DashDirection.normalized + _verticalVelocity * Time.deltaTime * Vector3.up);
					yield return null;
				}
			}
		}
		IEnumerator DashCancel(float startTime)
		{
			bool dashGrounded = Grounded;
			while (Time.time < startTime + dashDuration)
			{
				if(!dashGrounded && Grounded)
                {
					CancelDash();
					yield break;
                }
				yield return null;
			}
		}
		void CancelDash()
		{
			_dashCancel = true;
			_dashCancel = false;
		}
		Vector3 DashDirection
        {
            get
			{
				Vector2 move = _input.move != Vector2.zero ? _input.move : Vector2.up;
                if (GroundedSphere || dashInInputDirection)
                {
                    Vector3 normal = Physics.Raycast(transform.position, Vector3.down, out RaycastHit hit, GroundedRadius * 2, GroundLayers, QueryTriggerInteraction.Ignore) ? hit.normal : Vector3.up;
                    return Vector3.ProjectOnPlane(transform.right * move.x + transform.forward * move.y, normal);
                    //return transform.right * move.x + transform.forward * move.y;
                }
                else
                {
                    return transform.right * move.x + _mainCamera.transform.forward * move.y;
                }
            }
        }

        private static float ClampAngle(float lfAngle, float lfMin, float lfMax)
		{
			if (lfAngle < -360f) lfAngle += 360f;
			if (lfAngle > 360f) lfAngle -= 360f;
			return Mathf.Clamp(lfAngle, lfMin, lfMax);
		}

		private void OnDrawGizmosSelected()
		{
			Color transparentGreen = new Color(0.0f, 1.0f, 0.0f, 0.35f);
			Color transparentRed = new Color(1.0f, 0.0f, 0.0f, 0.35f);

			if (Grounded) Gizmos.color = transparentGreen;
			else Gizmos.color = transparentRed;

			// when selected, draw a gizmo in the position of, and matching radius of, the grounded collider
			Gizmos.DrawSphere(GroundedSpherePosition, GroundedRadius);

			if (LeftWallSphere) Gizmos.color = transparentGreen;
			else Gizmos.color = transparentRed;

			// when selected, draw a gizmo in the position of, and matching radius of, the grounded collider
			Gizmos.DrawSphere(LeftWallSpherePosition, GroundedRadius);

			if (RightWallSphere) Gizmos.color = transparentGreen;
			else Gizmos.color = transparentRed;

			// when selected, draw a gizmo in the position of, and matching radius of, the grounded collider
			Gizmos.DrawSphere(RightWallSpherePosition, GroundedRadius);

			if (ClimbSphere) Gizmos.color = transparentGreen;
			else Gizmos.color = transparentRed;

			// when selected, draw a gizmo in the position of, and matching radius of, the grounded collider
			Gizmos.DrawSphere(ClimbSpherePosition, GroundedRadius);
		}
	}
}