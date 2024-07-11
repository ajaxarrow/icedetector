import 'package:flutter/material.dart';
import 'package:icedetector/models/app_user.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool showPassword = true;
  bool isRegister = false;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  void resetForm(){
    _form.currentState!.reset();
    emailController.text = '';
    usernameController.text = '';
    passwordController.text = '';
  }


  @override
  Widget build(BuildContext context) {
    void submit() async{
      final isValid = _form.currentState!.validate();

      AppUser user = AppUser(
          name: usernameController.text,
          password: passwordController.text,
          email: emailController.text,
          context: context
      );

      if(!isValid){
        return;
      }
      _form.currentState!.save();
      if(isRegister){
        await user.register();
        Navigator.of(context).pushReplacementNamed('/redirect');
      } else {
        await user.login();
        Navigator.of(context).pushReplacementNamed('/redirect');
      }
    }
    return SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(
                top: 50,
                left: 25,
                right: 25
            ),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'IceCount AI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Text(
                          isRegister ? 'Create Account!' : 'Welcome Back!',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                        Text(
                          isRegister ? 'Please register here to continue' : 'Please login here to continue',
                          style: const TextStyle(
                              fontSize: 16
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        isRegister ? const SizedBox(
                          height: 20,
                        ) : const SizedBox.shrink(),
                        isRegister ? TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Username',
                          ),
                          validator: (value){
                            if (value!.trim().isEmpty || value == null || value!.trim().length < 4  ){
                              return 'Username must atleast have 5 characters';
                            }
                            return null;
                          },
                        ) : const SizedBox.shrink(),
                        isRegister ? const SizedBox(
                          height: 15,
                        ) : const SizedBox.shrink(),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: showPassword,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                    showPassword ? Icons.visibility : Icons.visibility_off
                                ),
                                onPressed: (){
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                              )
                          ),
                          validator: (value){
                            if (value!.trim().isEmpty || value == null || value!.trim().length < 8  ){
                              return 'Password must atleast have 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18)
                            ),
                            onPressed: submit,
                            child: Text(
                              isRegister ? 'Register' : 'Login',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isRegister ? 'Already have an account?' : 'New to IceCount?'),
                            TextButton(
                                onPressed: (){
                                  resetForm();
                                  setState(() {
                                    isRegister = !isRegister;
                                  });
                                },
                                child: Text(isRegister ? 'Login here' : 'Register Here')
                            )
                          ],
                        )
                      ],
                    ),
                  )
              ),
            ),
          ),
        )
    );
  }
}
