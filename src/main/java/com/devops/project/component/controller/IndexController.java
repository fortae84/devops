package com.devops.project.component.controller;

import java.net.InetAddress;
import java.net.UnknownHostException;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class IndexController {

	
	@GetMapping(path = "/")
	public String index(Model model) throws UnknownHostException  {
		model.addAttribute("hostname", InetAddress.getLocalHost().getHostName());
		model.addAttribute("ip", InetAddress.getLocalHost().getHostAddress());
		return "index";
	}
	
}
