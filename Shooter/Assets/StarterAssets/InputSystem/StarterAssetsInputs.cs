using UnityEngine;
using DG.Tweening;
using System.Collections;
#if ENABLE_INPUT_SYSTEM
using UnityEngine.InputSystem;
#endif

namespace StarterAssets
{
	public class StarterAssetsInputs : MonoBehaviour
	{
		[Header("Character Input Values")]
		public Vector2 move;
		public Vector2 look;
		public bool jump;
		public bool sprint;
		public bool dash;
        public bool zoomIn;
		public bool shoot, shootHeld;

		[Header("Movement Settings")]
		public bool analogMovement;

		[Header("Mouse Cursor Settings")]
		public bool cursorLocked = true;
		public bool cursorInputForLook = true;

		[Header("Accessibility Settings")]
		public bool zoomInToggle;
		public bool shootToggle;

        FirstPersonController First { get { return GetComponent<FirstPersonController>(); } }
		ThirdPersonController Third { get { return GetComponent<ThirdPersonController>(); } }

#if ENABLE_INPUT_SYSTEM
		public void OnMove(InputAction.CallbackContext value)
		{
			move = value.ReadValue<Vector2>();
		}

		public void OnLook(InputAction.CallbackContext value)
		{
			if(cursorInputForLook)
			{
				look = value.ReadValue<Vector2>();
			}
		}

		public void OnJump(InputAction.CallbackContext value)
		{
			jump = value.ReadValueAsButton();
			if (value.started)
			{
				if(First != null && (First.Grounded || First.HasMidairJumps || First.OnWalled))
				{
					First.Jump();
				}
				else if(Third != null && (Third.Grounded || Third.HasMidairJumps))
                {
					Third.Jump();
                }
			}
		}

		public void OnSprint(InputAction.CallbackContext value)
		{
			sprint = value.ReadValueAsButton();
        }

        public void OnDash(InputAction.CallbackContext value)
        {
            dash = value.ReadValueAsButton();
            if (value.started)
            {
				if(First != null && (First.Grounded || First.HasMidairJumps) && (!First.dashMoveInputRequired || move != Vector2.zero))
				{
					First.Dash();
				}
				else if(Third != null && (Third.Grounded || Third.HasMidairJumps) && (!Third.dashMoveInputRequired || move != Vector2.zero))
                {
					Third.Dash();
                }
            }
        }

		public void OnZoom(InputAction.CallbackContext value)
		{
			if(zoomInToggle)
			{
				if(value.started)
				{
					zoomIn = !zoomIn;
				}
			}
			else
			{
				zoomIn = value.ReadValueAsButton();
			}
		}

		public void OnShoot(InputAction.CallbackContext value)
		{
			shoot = value.started;
			if(shoot)
			{
				if(TryGetComponent(out Hitscan hitscan))
				{
					hitscan.Shoot();
				}
			}
			if (shootToggle)
			{
				if (value.started)
				{
					shootHeld = !shootHeld;
				}
			}
			else
			{
				shootHeld = value.ReadValueAsButton();
			}
		}

#endif


		//public void MoveInput(Vector2 newMoveDirection)
		//{
		//	move = newMoveDirection;
		//} 
		//
		//public void LookInput(Vector2 newLookDirection)
		//{
		//	look = newLookDirection;
		//}
		//
		//public void JumpInput(bool newJumpState)
		//{
		//	jump = newJumpState;
		//}
		//
		//public void SprintInput(bool newSprintState)
		//{
		//	sprint = newSprintState;
		//}

		private void OnApplicationFocus(bool hasFocus)
		{
			SetCursorState(cursorLocked);
		}

		private void SetCursorState(bool newState)
		{
			Cursor.lockState = newState ? CursorLockMode.Locked : CursorLockMode.None;
		}
	}
	
}