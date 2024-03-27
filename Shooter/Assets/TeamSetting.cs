using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum Team
{
    Red,
    Blue,
    Green,
    Yellow
}
public class TeamSetting : MonoBehaviour
{
    [SerializeField] Team team;
    public Team Team { get { return team; } }
    
    public void SetTeam(Team setTeam)
    { this.team = setTeam; }
}
