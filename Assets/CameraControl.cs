using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SocialPlatforms;

public class CameraControl : MonoBehaviour
{
    [SerializeField] private GameObject target_obj = null;
    public float mmovespeed = 1;
    public float mroundspeed = 1;
    public float mscrollspeed = 1;

    [SerializeField]
    private Vector3 overviewPosition = Vector3.zero;
    [SerializeField]
    private Quaternion overviewRotate;


    void Start()
    {
        overviewPosition = transform.position;
        overviewRotate = transform.rotation;
    }

    // Update is called once per frame
    void Update()
    {
        CheckTargetObject();
        if (target_obj != null)
        {
            // 单个观测相机
            SetCameraRotate();
        }
        else
        {
            // 全景相机
            SetCameraPosition();
        }
        SetCameraScollorPosition();
    }


    public void SetTargetObj(GameObject target)
    {
        if (target == null)
        {
            transform.position = overviewPosition;
            transform.rotation = overviewRotate;
        }
        else
        {
            overviewPosition = transform.position;
        }
        target_obj = target;
    }


    public void CheckTargetObject()
    {
        if (target_obj)
        {
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                SetTargetObj(null);
            }
        }
        else
        {
            if (Input.GetMouseButton(0))
            {
                // 创建一条点击位置为光标位置的射线
                Ray rays = Camera.main.ScreenPointToRay(Input.mousePosition);
                // 将射线以黄色的表示出来
                Debug.DrawRay(rays.origin, rays.direction * 100, Color.yellow);
                // 创建一个RayCast变量用于存储返回信息
                RaycastHit hit;
                // 将创建的射线投射出去并将反馈信息存储到hit中
                if (Physics.Raycast(rays, out hit))
                {
                    //获取被射线碰到的对象transfrom变量
                    SetTargetObj(hit.transform.gameObject);
                }
            }
        }

    }

    private void SetCameraRotate() //摄像机围绕目标旋转操作
    {
        var mouse_x = Input.GetAxis("Mouse X");//获取鼠标X轴移动
        var mouse_y = -Input.GetAxis("Mouse Y");//获取鼠标Y轴移动

        if (Input.GetKey(KeyCode.Mouse0))
        {
            transform.RotateAround(target_obj.transform.position, Vector3.up, mouse_x * mroundspeed);
            transform.RotateAround(target_obj.transform.position, transform.right, mouse_y * mroundspeed);
        }
    }

    // 相机位置
    public void SetCameraPosition()
    {
        var mouse_x = Input.GetAxis("Mouse X");//获取鼠标X轴移动
        var mouse_y = -Input.GetAxis("Mouse Y");//获取鼠标Y轴移动
        if (Input.GetKey(KeyCode.Mouse1))
        {
            transform.Translate(Vector3.left * (mouse_x * mmovespeed) * Time.deltaTime);
            transform.Translate(Vector3.up * (mouse_y * mmovespeed) * Time.deltaTime);
        }
    }

    public void SetCameraScollorPosition()
    {
        Vector3 dir = Camera.main.ScreenPointToRay(Input.mousePosition).direction;
        transform.position += dir * Input.GetAxis("Mouse ScrollWheel") * mscrollspeed;
    }
}
