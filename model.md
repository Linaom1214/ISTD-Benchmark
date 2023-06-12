#Add Custom Model

You need to follow the process below to add custom model.

#Add Model File

1. Create a new **matlab Package** named *YourModel* in the model folder.
2. Create model file named run_*yourmodel*.m in the *YourModel* folder.
3. Model code specification:
```
  function re = run_ADDGD(img)
    code...
    code...
  
  end
```